# 🚀 Getting Started

## 1. Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_notchpay: ^0.2.0
```

Then run:

```bash
flutter pub get
```

---

## 2. Initialization

Initialize the SDK once, ideally at app startup (e.g. in `main.dart`):

```dart
import 'package:flutter_notchpay/flutter_notchpay.dart';

void main() {
  // Public key only — for Flutter apps (checkout, customers, payments, resources)
  NotchPay.init(publicKey: 'pk_live_...');

  // OR with a private key — for trusted backend Dart services only
  NotchPay.init(
    publicKey: 'pk_live_...',
    privateKey: 'sk_live_...',  // ⚠️ NEVER ship this in a mobile app binary
  );

  runApp(MyApp());
}
```

> **⚠️ Important:** Never embed your `sk_live_...` private key in a Flutter mobile app. Use it only in server-side Dart code (e.g. Serverpod, Shelf).

---

## 3. Opening the Checkout Sheet

The simplest way to accept a payment — opens a full-featured native Bottom Sheet:

```dart
import 'package:flutter_notchpay/flutter_notchpay.dart';

final result = await NotchPay.instance.checkout(
  context,
  request: const NotchPayCheckoutRequest(
    amount: 5000,
    currency: 'XAF',
    description: 'Premium subscription',
    customer: NotchPayCheckoutCustomer(
      name: 'Jean Dupont',
      email: 'jean@example.com',
      phone: '+237655728267',
    ),
  ),
);

if (result.isSuccess) {
  print('Payment succeeded! Ref: ${result.payment?.reference}');
} else if (result.isCancelled) {
  print('User cancelled.');
} else {
  print('Payment failed: ${result.error}');
}
```

---

## 4. Using Callbacks

You can also pass `onSuccess`, `onCancelled`, and `onError` callbacks directly:

```dart
await NotchPay.instance.checkout(
  context,
  request: request,
  onSuccess: (payment) {
    print('✅ Paid! Reference: ${payment.reference}');
  },
  onCancelled: () {
    print('🚫 Cancelled by user.');
  },
  onError: (error) {
    print('❌ Error: $error');
  },
);
```

---

## 5. Sandbox vs. Live Mode

The environment is **automatically detected** from your public key prefix:

| Key prefix    | Mode    |
|---------------|---------|
| `pk_test_...` | Sandbox |
| `pk_live_...` | Live    |

```dart
print(NotchPay.instance.environment);  // NotchPayEnvironment.sandbox or .live
print(NotchPay.instance.isSandbox);    // true / false
```

When sandbox is detected, the checkout sheet displays a small **"Sandbox mode — no real money will move"** banner at the top.

---

## 6. Pre-filling a Default Country

Speed up the checkout experience for a specific market by pre-setting a country:

```dart
NotchPay.init(
  publicKey: 'pk_live_...',
  defaultCountryCode: 'cm',  // ISO 3166-1 alpha-2 code (Cameroon)
);
```

---

## Next Steps

- 🎨 [Theme Presets & Customization](Theme-Presets-&-Customization)
- 🧪 [Testing & Sandbox Guide](Testing-&-Sandbox-Guide)
- ⚡ [API Reference & Backend Services](API-Reference-&-Backend-Services)
- 🔒 [Webhooks & Security](Webhooks-&-Security)
