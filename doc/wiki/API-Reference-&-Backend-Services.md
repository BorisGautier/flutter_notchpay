# ⚡ API Reference & Backend Services

A complete reference for all 10 NotchPay API services exposed by this SDK.

---

## Key Requirements at a Glance

| Service              | Key Required    | Typical Use                          |
|----------------------|-----------------|--------------------------------------|
| `payments`           | Public          | Checkout flows, payment tracking     |
| `customers`          | Public          | CRM — create/update/list customers   |
| `resources`          | Public          | Countries, currencies, channels list |
| `paymentMethods`     | Public          | List saved payment methods           |
| `identity`           | Public          | KYC / mobile number validation       |
| `recipients`         | **Private** ⚠️  | Manage payout beneficiaries          |
| `transfers`          | **Private** ⚠️  | Initiate & track disbursements       |
| `refunds`            | **Private** ⚠️  | Fetch/list refunds                   |
| `balance`            | **Private** ⚠️  | Account balance inquiry              |
| `sync`               | **Private** ⚠️  | Sub-account synchronization          |

> ⚠️ **Private key services** must only be used from trusted backend Dart code (e.g. Serverpod, Shelf). **Never ship `sk_live_...` inside a Flutter mobile app binary.**

---

## 1. Payments Service

```dart
final svc = NotchPay.instance.payments;

// Initialize a new payment
final payment = await svc.initialize(
  const NotchPayCheckoutRequest(
    amount: 5000,
    currency: 'XAF',
    description: 'Order #42',
    customer: NotchPayCheckoutCustomer(
      name: 'Ada Lovelace',
      email: 'ada@example.com',
      phone: '+237655728267',
    ),
  ),
);

// Fetch a payment by reference
final fetched = await svc.fetch(payment.reference);

// List payments (paginated)
final page = await svc.list(limit: 20, page: 1);

// Complete a Mobile Money payment
final completed = await svc.complete(
  payment.reference,
  channel: 'cm.mtn',
  data: {'phone': '+237655728267'},
);

// Cancel a payment
await svc.cancel(payment.reference);
```

**`NotchPayPayment` key fields:**

| Field              | Type                      | Description                        |
|--------------------|---------------------------|------------------------------------|
| `reference`        | `String`                  | Unique payment identifier          |
| `amount`           | `double`                  | Amount in the payment currency     |
| `currency`         | `String`                  | ISO 4217 currency code             |
| `status`           | `NotchPayPaymentStatus`   | Current payment state              |
| `customer`         | `NotchPayCustomer?`        | Linked customer object             |
| `channel`          | `String?`                 | Payment channel used               |
| `authorizationUrl` | `String?`                 | URL for card / redirect payments   |

**`NotchPayPaymentStatus` values:** `pending`, `processing`, `complete`, `failed`, `canceled`, `rejected`, `expired`, `unknown` — plus `.isFinal` and `.isSuccess` getters.

---

## 2. Customers Service

```dart
final svc = NotchPay.instance.customers;

final customer = await svc.create(
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  phone: '+237655728267',
  description: 'VIP customer',
  address: const NotchPayAddress(country: 'cm', city: 'Douala'),
);

final page     = await svc.list(limit: 20, page: 1);
final fetched  = await svc.fetch(customer.reference!);
final updated  = await svc.update(customer.reference!, name: 'Ada, Countess of Lovelace');

await svc.block(customer.reference!);
await svc.unblock(customer.reference!);
await svc.delete(customer.reference!);
```

---

## 3. Resources Service

```dart
final svc = NotchPay.instance.resources;

final channels   = await svc.channels(country: 'cm');  // Filter by country code
final currencies = await svc.currencies();
final countries  = await svc.countries();
```

**`NotchPayChannel` key fields:** `code` (e.g. `cm.mtn`), `name`, `countries`, `currencies`, `kind` (`NotchPayChannelKind`: `mtn`, `orange`, `mobileMoney`, `card`, `bank`, `other`).

---

## 4. Payment Methods Service

```dart
final svc = NotchPay.instance.paymentMethods;

final methods = await svc.list();
final method  = await svc.fetch('pm.abc123');
```

**`NotchPayPaymentMethod` key fields:** `reference`, `type`, `brand`, `last4`.

---

## 5. Identity Service (KYC)

```dart
final svc = NotchPay.instance.identity;

// Fetch account identity info
final identity = await svc.fetch('account_reference');

// Validate a mobile money number
final result = await svc.validate(
  accountNumber: '655728267',
  channel: 'cm.mtn',
);

print(result.valid);  // true / false
print(result.name);   // Full name of account holder (if available)
```

---

## 6. Balance Service *(Private Key Required)*

```dart
final svc = NotchPay.instance.balance;

final balances = await svc.fetch();
for (final b in balances) {
  print('${b.currency}: available=${b.available}, pending=${b.pending}');
}
```

---

## 7. Recipients Service *(Private Key Required)*

Manage payout beneficiaries (bank accounts, Mobile Money numbers):

```dart
final svc = NotchPay.instance.recipients;

final recipient = await svc.create(
  name: 'Boris Gautier',
  country: 'cm',
  currency: 'XAF',
  channel: 'cm.mtn',
  accountNumber: '655728267',
  phone: '+237655728267',
);

final page    = await svc.list();
final fetched = await svc.fetch(recipient.reference!);
await svc.delete(recipient.reference!);
```

---

## 8. Transfers Service *(Private Key Required)*

Initiate disbursements to recipients:

```dart
final svc = NotchPay.instance.transfers;

// Standard transfer to a saved recipient
final transfer = await svc.initiate(
  recipientReference: recipient.reference!,
  amount: 10000,
  currency: 'XAF',
  description: 'Supplier payment',
);

// Direct transfer (no saved recipient needed)
final direct = await svc.direct(
  amount: 5000,
  currency: 'XAF',
  channel: 'cm.orange',
  accountNumber: '698765432',
  name: 'Jean Dupont',
  description: 'Commission payout',
);

final page     = await svc.list();
final fetched  = await svc.fetch(transfer.reference!);
```

---

## 9. Refunds Service *(Private Key Required)*

```dart
final svc = NotchPay.instance.refunds;

final page   = await svc.list();
final refund = await svc.fetch('ref.abc123');
```

**`NotchPayRefund` key fields:** `reference`, `amount`, `currency`, `transaction`, `reason`, `status`.

---

## 10. Sync / Sub-accounts Service *(Private Key Required)*

```dart
final svc = NotchPay.instance.sync;

final accounts   = await svc.list();
final account    = await svc.fetch('sync.abc123');
final newAccount = await svc.initialize(
  callback: 'https://myapp.com/notchpay/callback',
  permissions: ['payments.read', 'transfers.write'],
);
await svc.authorize('sync.abc123');
```

---

## 11. Utility Classes

These helpers are exported for building custom UIs on top of the raw services:

```dart
// Phone normalization & operator detection (Cameroon)
NotchPayPhoneUtils.normalize('+237 655 728 267');           // '655728267'
NotchPayPhoneUtils.detectCameroonOperator('655728267');     // NotchPayChannelKind.orange
NotchPayPhoneUtils.isValidCameroonMobile('655728267');      // true

// Card brand detection & Luhn validation (client-side only)
NotchPayCardUtils.detectBrand('4242424242424242');          // NotchPayCardBrand.visa
NotchPayCardUtils.isValidLuhn('4242424242424242');          // true
NotchPayCardUtils.isValidExpiry('12/29');                   // true
NotchPayCardUtils.formatForDisplay('4242424242424242');     // '4242 4242 4242 4242'

// Currency display formatting
NotchPayCurrencyFormatter.format(1500, 'XAF');             // '1 500 XAF'
NotchPayCurrencyFormatter.format(19.9, 'USD');             // '19.90 USD'
```

---

## Next Steps

- 🔒 [Webhooks & Security](Webhooks-&-Security)
- 🧪 [Testing & Sandbox Guide](Testing-&-Sandbox-Guide)
