# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-07-28

### Added

- **Checkout callbacks** — `NotchPay.checkout()` now accepts three optional
  callback parameters (`onSuccess`, `onCancelled`, `onError`) as a convenient
  alternative to `await`-ing the returned `Future` and switching on the
  result status. The `Future` is still returned and both styles can be used
  together. No breaking change.
- **Ready-made theme presets** — four named factory constructors on
  `NotchPayThemeData`: `darkMode()` (dark surface, NotchPay violet),
  `emerald()` (green accent, white surface), `purple()` (deep-purple on
  near-black), and `ocean()` (sky-blue on dark-navy). All presets are
  compatible with `copyWith()` for further customization.
- `NotchPayEnvironment` (`sandbox`/`live`), detected automatically from the
  public key. `NotchPay.instance.environment` / `.isSandbox` / `.isLive`
  expose it, and `checkout()` shows a "Sandbox mode" banner automatically
  when a test key is detected.
- The checkout sheet now caps its own width and stays centered on tablets,
  desktop, and web instead of stretching edge-to-edge.
- `.github/labels.yml` + a sync workflow: repository labels are now defined
  as code.
- `.github/SETUP.md`: one-time repository admin checklist (branch
  protection, pub.dev automated publishing, Codecov, labels).
- `doc/USAGE.md`: an exhaustive, section-by-section usage guide covering
  every service, model, and utility this package exposes.

## [0.1.0] - 2026-07-27

### Added

- Initial release.
- `NotchPay` facade: `init`/`instance` singleton plus standalone instances,
  exposing typed services for every NotchPay REST resource (customers,
  payments, channels/currencies/countries, payment methods, identity, and
  the backend-only recipients/transfers/refunds/balance/sync-account
  endpoints).
- `NotchPay.checkout()`: a native, themeable checkout bottom sheet with
  automatic MTN/Orange Money operator detection from the phone number,
  an animated confirmation screen while polling for the final payment
  status, and hosted-redirect support (Card and other channels) via
  `url_launcher`.
- Built-in English and French checkout strings (`NotchPayLocalizations`),
  auto-selected from the app's locale, overridable per call.
- Typed exceptions (`NotchPayApiException`, `NotchPayNetworkException`,
  `NotchPayConfigurationException`, `NotchPayCancelledException`) instead of
  raw HTTP errors.
- A documented public/private key security boundary: only the public key is
  ever required for the checkout flow; private-key-only methods fail fast
  with a clear error if no private key was configured.
- Full unit, widget, and integration test coverage; a runnable example app
  demonstrating theming, `flutter_bloc` state management, and a local
  `drift`-backed payment history cache.

[Unreleased]: https://github.com/BorisGautier/flutter_notchpay/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/BorisGautier/flutter_notchpay/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/BorisGautier/flutter_notchpay/releases/tag/v0.1.0
