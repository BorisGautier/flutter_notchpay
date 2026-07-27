# flutter_notchpay example

A small demo app showing how to integrate [`flutter_notchpay`](../) in a real
Flutter app.

It demonstrates:

- Initializing the SDK with `NotchPay.init(publicKey: ...)`.
- Opening the built-in checkout sheet with `NotchPay.instance.checkout(...)`.
- Handling the three possible outcomes (`success`, `cancelled`, `failed`).
- A small local history screen, caching completed payments on-device with
  [`drift`](https://drift.simonbinder.eu/) so the list survives app restarts.
- Wiring app state with [`flutter_bloc`](https://bloclibrary.dev) (`Cubit`s),
  as one example of how to structure a larger app around the SDK — the
  package itself has no dependency on Bloc.

## Running it

```sh
cd example
flutter pub get
dart run build_runner build -d   # generates the local database code
flutter run --dart-define=NOTCHPAY_PUBLIC_KEY=pk_test_your_public_key
```

Without `--dart-define`, the app falls back to a placeholder key and real
requests to NotchPay will fail with an authentication error — the UI flow
(channel selection, validation, theming) still works end-to-end against
that error so you can explore the sheet safely.

Get a public key from your [NotchPay dashboard](https://business.notchpay.co).
Only the **public** key is ever used here — see the root [README](../README.md#security)
for why the private key must never live in a mobile app.
