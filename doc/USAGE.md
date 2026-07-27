# flutter_notchpay — complete usage guide

This guide covers **every** feature of the package, service by service. For
a quick start, see the [root README](../README.md); come back here whenever
you need the full picture.

## Table of contents

- [1. Getting your API keys (NotchPay dashboard)](#1-getting-your-api-keys-notchpay-dashboard)
- [2. Installation](#2-installation)
- [3. Initializing the SDK](#3-initializing-the-sdk)
- [4. Sandbox vs. live mode](#4-sandbox-vs-live-mode)
- [5. The checkout flow](#5-the-checkout-flow)
- [6. Theming](#6-theming)
- [7. Localization](#7-localization)
- [8. Payments service](#8-payments-service)
- [9. Customers service](#9-customers-service)
- [10. Resources service (channels, currencies, countries)](#10-resources-service-channels-currencies-countries)
- [11. Payment methods service](#11-payment-methods-service)
- [12. Identity service](#12-identity-service)
- [13. Backend-only services (private key required)](#13-backend-only-services-private-key-required)
  - [13.1 Recipients](#131-recipients)
  - [13.2 Transfers](#132-transfers)
  - [13.3 Refunds](#133-refunds)
  - [13.4 Balance](#134-balance)
  - [13.5 Sync (Connect sub-accounts)](#135-sync-connect-sub-accounts)
- [14. Error handling](#14-error-handling)
- [15. Utilities](#15-utilities)
- [16. Multiple instances & backend usage](#16-multiple-instances--backend-usage)
- [17. Testing your integration](#17-testing-your-integration)

---

## 1. Getting your API keys (NotchPay dashboard)

1. Create an account or sign in at the
   [NotchPay Business dashboard](https://business.notchpay.co).
2. Once logged in, go to **Settings → API Keys** (sometimes labeled
   **Developers**).
3. You'll find two key pairs:
   - **Sandbox / Test keys** — safe to experiment with, no real money moves.
     These contain a `test` marker (e.g. `pk_test_...`, `sk_test_...`).
   - **Live keys** — move real money. Only switch to these once your
     integration is verified end-to-end in sandbox.
4. Copy the **public key** (`pk_...`) into your Flutter app. **Never** copy
   the **secret/private key** (`sk_...`) into a mobile app — see
   [Security](../README.md#security) and [Section 13](#13-backend-only-services-private-key-required).
5. NotchPay also requires your business/account to be validated (KYC)
   before you can move real money in live mode — this is done from the same
   dashboard under **Settings → Business** (or similar, per NotchPay's own
   onboarding flow).

There is nothing to configure on the dashboard for sandbox testing — the
test keys work immediately.

## 2. Installation

```yaml
dependencies:
  flutter_notchpay: ^0.1.0
```

```sh
flutter pub get
```

Import the single barrel file everywhere you need it:

```dart
import 'package:flutter_notchpay/flutter_notchpay.dart';
```

## 3. Initializing the SDK

Two ways to configure the SDK, pick whichever fits your app:

### 3.1 Shared singleton (`NotchPay.init` / `NotchPay.instance`)

The simplest option for most apps — configure once, use everywhere:

```dart
void main() {
  NotchPay.init(publicKey: 'pk_test_xxx');
  runApp(const MyApp());
}

// anywhere later:
NotchPay.instance.checkout(context, request: request);
```

- `NotchPay.isInitialized` tells you whether `init` has run yet.
- Calling `init` again (e.g. to switch environments at runtime) replaces
  the shared instance; the latest call wins.
- Accessing `NotchPay.instance` before `init` throws a
  `NotchPayConfigurationException` with a clear message — this is
  intentional, so a missing setup step fails loudly instead of crashing
  deep inside a checkout.

### 3.2 Standalone instances

Construct `NotchPay(...)` directly when you need more than one
configuration side by side — for example in tests, a multi-tenant backend,
or an app that supports multiple merchant accounts:

```dart
final notchPay = NotchPay(publicKey: 'pk_test_xxx');
// ... use notchPay.checkout(...), notchPay.payments, etc.
notchPay.dispose(); // closes the underlying HTTP client when you're done
```

Both constructors accept the same parameters:

| Parameter | Required | Description |
| --- | --- | --- |
| `publicKey` | ✅ | Safe to embed in a mobile app. |
| `privateKey` | ❌ | Backend-only — see [Section 13](#13-backend-only-services-private-key-required). |
| `baseUrl` | ❌ | Defaults to `https://api.notchpay.co`. Override to point at a mock server in tests. |
| `httpClient` | ❌ | Inject your own `http.Client` (e.g. `http.testing.MockClient`, or one with certificate pinning). |

## 4. Sandbox vs. live mode

The SDK detects, purely from the shape of your public key, whether you're
running in **sandbox** or **live** mode — no configuration needed:

```dart
NotchPay.instance.environment; // NotchPayEnvironment.sandbox or .live
NotchPay.instance.isSandbox;   // bool shorthand
NotchPay.instance.isLive;      // bool shorthand
```

A key is treated as sandbox when it contains a `test` marker as its own
segment (`pk_test_...`, `pk.test.xxx`, `sk-test-xxx`, matching NotchPay's
own convention, e.g. `acc.test_SD9b2dwJ2nqX8XEclNpEcGGc`). Anything else is
treated as live — an unrecognized key fails safe towards "this might move
real money".

`NotchPay.checkout()` uses this automatically: whenever a sandbox key is
detected, the checkout sheet shows a small amber **"Sandbox mode — no real
money will move"** banner at the top, so nobody — developer, QA, or a
customer during a demo — mistakes a test payment for a real one. Live mode
shows no banner at all, keeping the paid UI clean.

## 5. The checkout flow

```dart
final result = await NotchPay.instance.checkout(
  context,
  request: const NotchPayCheckoutRequest(
    amount: 1500,
    currency: 'XAF',
    description: 'Order #4831',
    customer: NotchPayCheckoutCustomer(phone: '+237655728267'),
    reference: 'order-4831',       // optional idempotency key
    metadata: {'orderId': '4831'}, // optional, echoed back by the API
  ),
  countryCode: 'cm', // ISO 3166-1 alpha-2; controls which channels are offered
);
```

### `NotchPayCheckoutRequest`

| Field | Type | Notes |
| --- | --- | --- |
| `amount` | `double` | Must be `> 0`. Major unit (e.g. `1500` for 1500 XAF). |
| `currency` | `String` | ISO 4217, e.g. `XAF`. |
| `description` | `String?` | Shown to the customer and merchant. |
| `customer` | `NotchPayCheckoutCustomer?` | At least one of `name`/`email`/`phone`. `phone` is required for Mobile Money. |
| `reference` | `String?` | Your own idempotency reference. |
| `metadata` | `Map<String, dynamic>` | Free-form, echoed back on fetch/webhooks. |

### What happens inside the sheet

1. **Loading** — the transaction is initialized (`payments.initialize`) and
   available channels are fetched (`resources.channels`) in parallel.
2. **Choose a payment method** — a list of channels (MTN, Orange, Card, ...)
   is shown, each with an auto-generated colored badge.
3. **Mobile Money channels** (MTN / Orange / generic mobile money): a phone
   field appears. As the customer types, the operator badge switches
   automatically between MTN and Orange based on the number's prefix
   (Cameroon prefixes; see [Section 15](#15-utilities)). On submit,
   `payments.complete` is called and the sheet starts polling.
4. **Card / other channels**: the SDK calls `payments.complete`, then opens
   the `authorization_url` NotchPay returns in a secure in-app browser tab
   (via `url_launcher`) — this package never touches a raw card number.
   The sheet then starts polling, same as Mobile Money.
5. **Processing** — an animated screen polls `payments.fetch` every 4
   seconds (up to a 5 minute timeout) until the transaction reaches a
   final status.
6. **Result** — a success or failure screen is shown; tapping its button
   closes the sheet and resolves the `Future` returned by `checkout()`.

The customer can close the sheet (✕ button) at any point; this resolves
with a `cancelled` result immediately — the transaction may still complete
server-side later, so if you need certainty, fetch it by reference
afterwards (`NotchPay.instance.payments.fetch(reference)`).

### `NotchPayCheckoutResult`

```dart
switch (result.status) {
  case NotchPayCheckoutStatus.success:
    // result.payment is non-null and result.payment!.status.isSuccess
    break;
  case NotchPayCheckoutStatus.cancelled:
    // the customer closed the sheet before a final status was reached
    break;
  case NotchPayCheckoutStatus.failed:
    // result.message explains why; result.payment may still be present
    break;
}

result.isSuccess; // shorthand for status == NotchPayCheckoutStatus.success
```

## 6. Theming

```dart
NotchPay.instance.checkout(
  context,
  request: request,
  theme: const NotchPayThemeData(
    primaryColor: Color(0xFF0EA5E9),
    onPrimaryColor: Colors.white,
    successColor: Color(0xFF16A34A),
    errorColor: Color(0xFFDC2626),
    borderRadius: 28,
    // surfaceColor / onSurfaceColor / mutedColor default to
    // NotchPayThemeData.light or .dark based on the ambient Brightness.
  ),
);
```

| Field | Default | Purpose |
| --- | --- | --- |
| `primaryColor` | NotchPay purple | Buttons, selected states, accents. |
| `onPrimaryColor` | white | Text/icons on top of `primaryColor`. |
| `surfaceColor` | light/dark preset | Sheet background. |
| `onSurfaceColor` | light/dark preset | Default text/icon color. |
| `mutedColor` | light/dark preset | Secondary text, borders. |
| `successColor` | green | Success screen. |
| `errorColor` | red | Failure screens. |
| `borderRadius` | `20` | Sheet, cards, and button corners. |
| `fontFamily` | ambient `Theme` font | Optional override. |

The sheet always stays comfortably readable on tablets, desktop and web: it
caps its own width and centers itself at the bottom of the screen instead
of stretching edge-to-edge.

## 7. Localization

Built-in English and French, auto-selected from
`Localizations.localeOf(context)` — no `localizationsDelegates` setup
required on your end. Override any string, or add a language, with
`NotchPayLocalizations`:

```dart
NotchPay.instance.checkout(
  context,
  request: request,
  localizations: const NotchPayLocalizations(
    payNow: 'Payer',
    mobileMoneyNumber: 'Numéro Mobile Money',
    phoneHint: '6XX XXX XXX',
    enterPhoneNumber: 'Entrez votre numéro',
    enterValidPhoneNumber: 'Numéro invalide',
    confirmOnYourPhone: 'Confirmez sur votre téléphone',
    mobileMoneyInstructions: '...',
    redirectInstructions: '...',
    choosePaymentMethod: 'Choisissez un moyen de paiement',
    paymentSuccessTitle: 'Paiement réussi',
    paymentSuccessMessage: '...',
    paymentFailedTitle: 'Échec du paiement',
    paymentCancelledTitle: 'Paiement annulé',
    paymentExpiredTitle: 'Paiement expiré',
    genericErrorMessage: '...',
    done: 'Terminé',
    close: 'Fermer',
    retry: 'Réessayer',
    sandboxModeBanner: 'Mode bac à sable',
  ),
);
```

(`NotchPayLocalizations.en` and `.fr` are public — read them for the exact
wording, or use `.copyWith`-style spreading by starting from one of them if
you only want to tweak a couple of strings... actually there's no
`copyWith` on this class by design, since every field is required: this
guarantees a custom translation can never accidentally ship with a blank
string.)

## 8. Payments service

`NotchPay.instance.payments` — the service powering `checkout()`, also
usable directly for advanced flows (e.g. building your own UI on top).

```dart
// Initialize a transaction (first step of any payment).
final payment = await NotchPay.instance.payments.initialize(
  const NotchPayCheckoutRequest(amount: 1500, currency: 'XAF'),
);

// Submit a channel to complete it (e.g. Mobile Money).
final updated = await NotchPay.instance.payments.complete(
  payment.reference,
  channel: 'cm.mtn',
  data: {'phone': '+237670123456'},
);

// Fetch the current state.
final current = await NotchPay.instance.payments.fetch(payment.reference);

// List, with optional filters.
final list = await NotchPay.instance.payments.list(
  status: NotchPayPaymentStatus.complete,
  channels: ['cm.mtn', 'cm.orange'],
  limit: 20,
  page: 1,
);

// Cancel a pending transaction.
await NotchPay.instance.payments.cancel(payment.reference);
```

`NotchPayPayment` fields: `reference`, `amount`, `currency`, `fee`,
`description`, `status` (`NotchPayPaymentStatus`), `customer`, `channel`,
`authorizationUrl`, `metadata`, `createdAt`, `updatedAt`, `raw` (untouched
JSON payload).

`NotchPayPaymentStatus`: `pending`, `processing`, `complete`, `failed`,
`canceled`, `rejected`, `expired`, `unknown` — plus `.isFinal` and
`.isSuccess` getters, and `NotchPayPaymentStatus.parse(String?)` if you ever
need to parse a raw status yourself (e.g. from a webhook payload).

## 9. Customers service

`NotchPay.instance.customers`:

```dart
final customer = await NotchPay.instance.customers.create(
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  phone: '+237655728267',
  description: 'VIP customer',
  address: const NotchPayAddress(country: 'cm', city: 'Douala'),
);

final page = await NotchPay.instance.customers.list(limit: 20, page: 1);
final fetched = await NotchPay.instance.customers.fetch(customer.reference!);
final updated = await NotchPay.instance.customers.update(
  customer.reference!,
  name: 'Ada, Countess of Lovelace',
);

await NotchPay.instance.customers.block(customer.reference!);
await NotchPay.instance.customers.unblock(customer.reference!);
await NotchPay.instance.customers.delete(customer.reference!);
```

`NotchPayCustomer` fields: `reference`, `name`, `email`, `phone`,
`description`, `address`, `shipping` (both `NotchPayAddress?`), `locked`,
`createdAt`, `updatedAt`, `raw`.

`NotchPayAddress` fields: `country`, `city`, `addressLine1`,
`addressLine2`.

## 10. Resources service (channels, currencies, countries)

`NotchPay.instance.resources` — read-only reference data, useful if you
build custom UI instead of (or alongside) `checkout()`:

```dart
final channels = await NotchPay.instance.resources.channels(country: 'cm');
final currencies = await NotchPay.instance.resources.currencies();
final countries = await NotchPay.instance.resources.countries();
```

`NotchPayChannel` fields: `code` (e.g. `cm.mtn`), `name`, `countries`,
`currencies`, `raw`, and a computed `kind` (`NotchPayChannelKind`: `mtn`,
`orange`, `mobileMoney`, `card`, `bank`, `other`) used to pick the right
icon/form.

`NotchPayCurrency` fields: `code`, `name`, `symbol`, `decimals`.

`NotchPayCountry` fields: `code`, `name`, `currency`, `dialCode`, `flag`.

## 11. Payment methods service

`NotchPay.instance.paymentMethods`:

```dart
final methods = await NotchPay.instance.paymentMethods.list();
final method = await NotchPay.instance.paymentMethods.fetch(methods.first.reference);
```

`NotchPayPaymentMethod` fields: `reference`, `type`, `brand`, `last4`,
`raw`.

## 12. Identity service

`NotchPay.instance.identity` — look up or validate the registered owner of
a Mobile Money / bank account number, e.g. to show "Paying to: AWA NGONO
MARIE" before the customer confirms, catching typos before money moves:

```dart
final identity = await NotchPay.instance.identity.fetch(
  accountNumber: '655728267',
  country: 'CM',
  type: 'mobile',
);
print(identity.name); // registered owner name, if found

final validated = await NotchPay.instance.identity.validate(
  accountNumber: '655728267',
  country: 'CM',
  type: 'mobile',
  name: 'Awa Ngono Marie',
);
print(validated.valid);
```

## 13. Backend-only services (private key required)

Everything in this section requires a **private key**
(`NotchPay(publicKey: ..., privateKey: 'sk_...')`) and **must only run in
trusted backend Dart code** (a server, a Cloud Function, ...) — never in
the Flutter app your users install. Calling any of these without a private
key throws `NotchPayConfigurationException` immediately, by design.

### 13.1 Recipients

```dart
final recipient = await backend.recipients.create(
  const NotchPayRecipient(
    reference: '', // ignored on create
    name: 'Boris Gautier',
    country: 'CM',
    currency: 'XAF',
    channel: 'cm.mobile',
    accountNumber: '655728267',
  ),
);

final all = await backend.recipients.list();
final one = await backend.recipients.fetch(recipient.reference);
await backend.recipients.delete(recipient.reference);
```

### 13.2 Transfers

```dart
final transfer = await backend.transfers.initiate(
  amount: 500,
  currency: 'XAF',
  channel: 'cm.mobile',
  recipient: {
    'account_number': '+237651608133',
    'country': 'CM',
    'name': 'Boris Gautier',
  },
  description: 'Payout',
);

// Or send directly without saving a recipient first:
final direct = await backend.transfers.direct(
  amount: 20000,
  currency: 'XAF',
  channel: 'cm.mobile',
  accountNumber: '655728267',
  description: 'Payout',
);

final all = await backend.transfers.list();
final one = await backend.transfers.fetch(transfer.reference);
```

### 13.3 Refunds

```dart
final refunds = await backend.refunds.list();
final refund = await backend.refunds.fetch(refunds.first.reference);
```

### 13.4 Balance

```dart
final balances = await backend.balance.fetch(); // List<NotchPayBalance>, one per currency
```

### 13.5 Sync (Connect sub-accounts)

For platform / marketplace integrations (NotchPay Connect):

```dart
final account = await backend.sync.initialize(
  callback: 'https://yourapp.com/notchpay/callback',
  permissions: ['payments', 'customers'],
  profileName: 'Sub-merchant name',
  profileEmail: 'submerchant@example.com',
);

final all = await backend.sync.list();
final one = await backend.sync.fetch(account.reference);
final authorized = await backend.sync.authorize(account.reference);
```

## 14. Error handling

Every failure surfaces as a typed subclass of the sealed `NotchPayException`
— never a raw `Exception` or an unhandled HTTP error:

```dart
try {
  await NotchPay.instance.payments.fetch('trx.unknown');
} on NotchPayApiException catch (e) {
  print('${e.statusCode} ${e.code}: ${e.message}');
  if (e.isNotFound) { /* ... */ }
  if (e.isValidationError) { /* e.errors has field-level details */ }
  if (e.isUnauthorized) { /* bad or missing key */ }
  if (e.isServerError) { /* NotchPay-side issue, safe to retry */ }
} on NotchPayNetworkException catch (e) {
  print('Network issue: ${e.message} (cause: ${e.cause})');
} on NotchPayConfigurationException catch (e) {
  print('SDK misuse: ${e.message}'); // e.g. missing private key
} on NotchPayCancelledException catch (e) {
  print(e.message);
}
```

`NotchPayException` is `sealed`, so a `switch` over it is exhaustiveness
checked by the Dart compiler if you prefer that style over try/catch.

## 15. Utilities

These power the checkout sheet and are also exported for building your own
UI on top of the services above.

```dart
// Phone / Mobile Money operator detection (Cameroon).
NotchPayPhoneUtils.normalize('+237 655 728 267');           // '655728267'
NotchPayPhoneUtils.detectCameroonOperator('655728267');     // NotchPayChannelKind.orange
NotchPayPhoneUtils.isValidCameroonMobile('655728267');      // true

// Card helpers (client-side validation only — this package never
// transmits raw card numbers itself; Card payments go through NotchPay's
// own hosted page).
NotchPayCardUtils.detectBrand('4242424242424242');   // NotchPayCardBrand.visa
NotchPayCardUtils.isValidLuhn('4242424242424242');   // true
NotchPayCardUtils.isValidExpiry('12/29');            // true unless in the past
NotchPayCardUtils.formatForDisplay('4242424242424242'); // '4242 4242 4242 4242'

// Currency display formatting used throughout the sheet.
NotchPayCurrencyFormatter.format(1500, 'XAF'); // '1 500 XAF'
NotchPayCurrencyFormatter.format(19.9, 'USD'); // '19.90 USD'
```

## 16. Multiple instances & backend usage

Everything under `lib/src/client`, `lib/src/models`, and
`lib/src/services` is plain Dart with no Flutter dependency — only
`lib/src/ui` and the `checkout()` method need Flutter. That means the same
services classes documented above can run in a Dart backend (a server
handling transfers/refunds/balance with the private key) if that's a
convenient way to share models/serialization with your Flutter app. The
`NotchPay` facade itself still requires Flutter (for `checkout()`); build
directly on `NotchPayClient` + individual services if you need a
Flutter-free backend usage.

## 17. Testing your integration

Every constructor accepts an `httpClient`, so you can fully mock the
network in your own tests exactly like this package's own test suite does:

```dart
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final notchPay = NotchPay(
  publicKey: 'pk_test_123',
  httpClient: MockClient((request) async {
    if (request.url.path == '/payments') {
      return http.Response('{"transaction": {"reference": "trx.abc", ...}}', 200);
    }
    return http.Response('{}', 404);
  }),
);
```

See this package's own `test/` and `integration_test/` folders for complete
examples, including a full end-to-end widget test of the checkout sheet.
