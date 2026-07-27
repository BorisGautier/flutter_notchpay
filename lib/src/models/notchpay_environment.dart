/// Which NotchPay environment a key belongs to.
///
/// NotchPay marks sandbox credentials and resources with a `test` marker
/// (e.g. an account reference such as `acc.test_SD9b2dwJ2nqX8XEclNpEcGGc`).
/// This package uses the same convention to tell, from the key alone,
/// whether a checkout is about to move real money or not — so the checkout
/// sheet can warn the customer with a "Sandbox mode" banner instead of
/// silently taking a test payment for a live one (or vice versa).
enum NotchPayEnvironment {
  /// Real money moves. No sandbox marker was found in the key.
  live,

  /// A sandbox/test key. No real money moves.
  sandbox;

  /// Detects the environment a [key] (public or private) belongs to.
  ///
  /// A key is considered [sandbox] when it contains a `test` marker
  /// (case-insensitive, e.g. `pk_test_...`, `pk.test.xxx`, `sk_test_xxx`).
  /// Everything else is treated as [live], so an unrecognized or malformed
  /// key fails safe towards the assumption that it might move real money.
  static NotchPayEnvironment detect(String key) {
    final normalized = key.toLowerCase();
    final isSandbox = RegExp(r'(^|[._-])test([._-]|$)').hasMatch(normalized);
    return isSandbox ? NotchPayEnvironment.sandbox : NotchPayEnvironment.live;
  }

  /// Whether this is [sandbox].
  bool get isSandbox => this == NotchPayEnvironment.sandbox;

  /// Whether this is [live].
  bool get isLive => this == NotchPayEnvironment.live;
}
