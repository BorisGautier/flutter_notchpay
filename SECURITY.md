# Security Policy

`flutter_notchpay` handles payment credentials, so security issues are taken
seriously and fixed as a priority.

## Reporting a vulnerability

**Please do not open a public issue for security vulnerabilities.**

Instead, use GitHub's private reporting flow:
[Report a vulnerability](https://github.com/BorisGautier/flutter_notchpay/security/advisories/new).

Include, if possible:

- A description of the vulnerability and its impact.
- Steps to reproduce, or a minimal proof of concept.
- The version(s) of `flutter_notchpay` affected.

You should receive an acknowledgement within a few days. We'll work with you
to understand and confirm the issue, prepare a fix, and coordinate
disclosure timing before any public write-up.

## Supported versions

Only the latest published `0.x` minor version receives security fixes until
this package reaches `1.0.0`, after which the two most recent major versions
will be supported.

## Key-handling guidance for users of this package

These are the practices this package is designed around, and that your app
should follow too:

1. **Never embed your NotchPay private/secret key (`sk_...`) in a mobile
   app.** It grants full account access (transfers, refunds, balance,
   recipients). `NotchPayClient` and every service that requires it
   (`transfers`, `recipients`, `refunds`, `balance`, `sync`) will throw a
   `NotchPayConfigurationException` if no private key is configured — this
   is intentional friction, not a bug to work around by hardcoding one in
   your Flutter app. Only supply `privateKey` from trusted backend Dart
   code.
2. **Only the public key (`pk_...`) belongs in your Flutter app**, passed to
   `NotchPay.init` / `NotchPay(...)`. It is the only credential
   `NotchPay.checkout()` needs.
3. **Build a hardened release.** Use Flutter's
   [`--obfuscate --split-debug-info`](https://docs.flutter.dev/deployment/obfuscate)
   flags for release builds to make reverse engineering harder.
4. **Rotate a key immediately** if you believe it was exposed (committed to
   a public repo, logged, etc.), from your NotchPay dashboard.
5. This package does not log request headers, keys, or raw response bodies
   by itself. If you add your own logging around `NotchPayClient`/services,
   make sure it doesn't capture the `Authorization` or `X-Grant` headers.
