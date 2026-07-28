# 🔒 Webhooks & Security

---

## 1. Key Security Rules

| Key Type      | Where to Use                | Where NEVER to Use       |
|---------------|-----------------------------|--------------------------|
| `pk_live_...` | Flutter app, mobile binary  | Nowhere unsafe           |
| `sk_live_...` | Server-side Dart only       | ⛔ NEVER in a mobile app |

Your private key (`sk_live_...` or `sk_test_...`) has full access to your NotchPay account — transfers, balance, recipients. If exposed in a mobile app binary, it can be extracted and misused.

---

## 2. Webhook Signature Verification

When NotchPay sends a webhook event to your backend (e.g. a `payment.complete` notification), it signs the request body with your secret key using **HMAC-SHA256**.

You must verify this signature before processing any webhook to prevent replay attacks and spoofing.

### Using the Built-in Utility

```dart
import 'package:flutter_notchpay/flutter_notchpay.dart';

bool isValid = NotchPayWebhookUtils.verifySignature(
  payload: rawRequestBody,     // The raw UTF-8 request body string
  signature: requestHeaders['x-notch-signature']!,  // NotchPay's signature header
  secretKey: 'sk_live_...',    // Your private/secret key
);

if (!isValid) {
  // Reject the request — it did not come from NotchPay
  return Response(statusCode: 401);
}

// Safe to process the event
```

### How It Works

NotchPay computes:

```
HMAC-SHA256(key = secretKey, message = rawRequestBody)
```

`NotchPayWebhookUtils.verifySignature` recomputes the same HMAC and performs a **constant-time comparison** to prevent timing attacks.

---

## 3. Dart / Serverpod / Shelf Backend Example

Here is a complete webhook handler for a Shelf server:

```dart
import 'package:shelf/shelf.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';

Handler webhookHandler() {
  return (Request request) async {
    final body = await request.readAsString();
    final signature = request.headers['x-notch-signature'] ?? '';

    final valid = NotchPayWebhookUtils.verifySignature(
      payload: body,
      signature: signature,
      secretKey: 'sk_live_...',
    );

    if (!valid) {
      return Response(401, body: 'Invalid signature');
    }

    final event = jsonDecode(body) as Map<String, dynamic>;
    final eventType = event['event'] as String?;

    switch (eventType) {
      case 'payment.complete':
        // Handle successful payment
        final ref = event['data']?['reference'];
        print('Payment $ref completed ✅');
        break;
      case 'payment.failed':
        // Handle failed payment
        break;
      default:
        print('Unhandled event type: $eventType');
    }

    return Response.ok('OK');
  };
}
```

---

## 4. Card Payment Security

This package **never collects or transmits raw card numbers**.

Card payments are handled entirely through NotchPay's **own hosted, PCI-compliant payment page**, which opens in a secure in-app browser tab (`SFSafariViewController` on iOS, `Chrome Custom Tabs` on Android). The SDK only receives the final payment result (success/failure/reference) — never the card details themselves.

---

## 5. `NotchPayConfigurationException` as a Safety Net

Any service requiring a private key (Balance, Transfers, Recipients, Refunds, Sync) will throw `NotchPayConfigurationException` instead of silently failing if no private key was provided at initialization:

```dart
try {
  await NotchPay.instance.balance.fetch(); // No privateKey was passed → throws
} on NotchPayConfigurationException catch (e) {
  print(e.message); // "A private key is required for this operation."
}
```

This prevents accidental unauthenticated calls to sensitive endpoints.

---

## 6. Security Reporting

If you discover a security vulnerability in this package, **please do not open a public GitHub issue**.

Instead, follow the responsible disclosure policy in [SECURITY.md](https://github.com/BorisGautier/flutter_notchpay/blob/main/SECURITY.md):
- Email the maintainer directly (see `SECURITY.md` for contact details).
- Include a clear description and, if possible, a proof of concept.

Vulnerabilities are typically addressed within **48 hours** for critical issues.

---

## Next Steps

- 🚀 [Getting Started](Getting-Started)
- ⚡ [API Reference & Backend Services](API-Reference-&-Backend-Services)
- 🧪 [Testing & Sandbox Guide](Testing-&-Sandbox-Guide)
