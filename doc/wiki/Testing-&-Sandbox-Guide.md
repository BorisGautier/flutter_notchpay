# 🧪 Testing & Sandbox Guide

---

## 1. Sandbox Environment

NotchPay provides a fully functional Sandbox environment. Your Sandbox keys look like:

```
pk_test.VbnmyXvK...   ← Public Key (safe to use in Flutter apps)
sk_test.BLYozmFD...   ← Private Key (backend only, NEVER in mobile apps)
```

The SDK auto-detects Sandbox mode from your public key prefix. When active, the checkout sheet shows a `"Sandbox mode — no real money will move"` banner.

---

## 2. Mobile Money Test Phone Numbers

Use these phone numbers to simulate different payment scenarios in the Sandbox:

| Phone Number     | Scenario                      |
|------------------|-------------------------------|
| `+237670000000`  | ✅ Payment **succeeds**       |
| `+237670000001`  | 💸 **Insufficient funds**     |
| `+237670000002`  | ❌ **Failure** (other reason) |
| `+237670000003`  | ⏰ **Timeout**                |
| `+237670000004`  | 🚫 **Cancelled** by user      |

> **Note:** Phone numbers must be valid Cameroonian format (9-digit numbers starting with `6`). The Sandbox API validates format strictly.

---

## 3. Unit & Widget Testing (Mocked Network)

Every `NotchPay` constructor and service accepts a custom `httpClient`, allowing you to fully mock the network without any real HTTP calls:

```dart
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';

final mockClient = MockClient((request) async {
  if (request.url.path == '/payments') {
    return http.Response(
      '{"transaction": {"reference": "trx.abc123", "amount": 1000, "currency": "XAF", "status": "pending"}}',
      200,
    );
  }
  return http.Response('{"code": 404, "message": "Not found"}', 404);
});

final notchPay = NotchPay(
  publicKey: 'pk_test_fake_key',
  httpClient: mockClient,
);

test('initializes a payment', () async {
  final payment = await notchPay.payments.initialize(
    const NotchPayCheckoutRequest(
      amount: 1000,
      currency: 'XAF',
      description: 'Test',
      customer: NotchPayCheckoutCustomer(name: 'Test User'),
    ),
  );
  expect(payment.reference, 'trx.abc123');
});
```

### Running the Unit Test Suite

```bash
flutter test
```

All 132 unit, widget, model, and service tests run without any network access.

---

## 4. Live Sandbox API Integration Tests

To run real HTTP tests against the NotchPay Sandbox servers, pass your credentials via environment variables (never hardcode them in source code):

### Step 1 — Set Environment Variables

**Windows (PowerShell):**
```powershell
$env:NOTCHPAY_TEST_PUBLIC_KEY="pk_test.VbnmyXvK..."
$env:NOTCHPAY_TEST_PRIVATE_KEY="sk_test.BLYozmFD..."
```

**Linux / macOS:**
```bash
export NOTCHPAY_TEST_PUBLIC_KEY="pk_test.VbnmyXvK..."
export NOTCHPAY_TEST_PRIVATE_KEY="sk_test.BLYozmFD..."
```

### Step 2 — Run Live Tests

```bash
flutter test test/live_api_test.dart
```

### What the Live Tests Validate

| Test | What it verifies |
|------|-----------------|
| 1. Environment auto-detection | SDK detects `sandbox` from key prefix |
| 2. Payment initialization & fetch | `POST /payments` → real reference returned & fetchable |
| 3. Mobile Money success (`+237670000000`) | `POST /payments/{ref}` → status flows correctly |
| 4. Insufficient funds (`+237670000001`) | Failure scenario handled without exception |
| 5. Account balance (private key) | `GET /balance` with `X-Grant` header |
| 6. Recipients & Transfers list (private key) | `GET /beneficiaries`, `GET /transfers` |

---

## 5. CI/CD Integration

For GitHub Actions, add your keys as **Repository Secrets** (Settings → Secrets and Variables → Actions):

```yaml
# .github/workflows/ci.yml
- name: Run live integration tests
  env:
    NOTCHPAY_TEST_PUBLIC_KEY: ${{ secrets.NOTCHPAY_TEST_PUBLIC_KEY }}
    NOTCHPAY_TEST_PRIVATE_KEY: ${{ secrets.NOTCHPAY_TEST_PRIVATE_KEY }}
  run: flutter test test/live_api_test.dart
```

> The live test suite gracefully **skips all assertions** if the environment variables are not set, so it's always safe to run `flutter test` without keys (e.g. in a contributor's fork without access to secrets).

---

## 6. Testing Error Handling

Test exception types using `throwsA`:

```dart
test('throws NotchPayApiException on 401', () async {
  final notchPay = NotchPay(
    publicKey: 'pk_test_invalid',
    httpClient: MockClient((_) async => http.Response('{"code": 401, "message": "Unauthorized"}', 401)),
  );

  expect(
    () => notchPay.payments.initialize(request),
    throwsA(isA<NotchPayApiException>()),
  );
});
```

### Exception Types

| Exception | When thrown |
|-----------|-------------|
| `NotchPayApiException(statusCode, code)` | Non-2xx HTTP response |
| `NotchPayNetworkException(cause)` | Socket errors, timeouts |
| `NotchPayConfigurationException` | Missing private key for restricted endpoint |
| `NotchPayCancelledException` | Checkout sheet dismissed by user |

---

## Next Steps

- ⚡ [API Reference & Backend Services](API-Reference-&-Backend-Services)
- 🔒 [Webhooks & Security](Webhooks-&-Security)
