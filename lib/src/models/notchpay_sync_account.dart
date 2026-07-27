/// A NotchPay Connect sub-account (`acc.xxx`), used to grant a platform
/// scoped access to a merchant's account.
///
/// **Backend use only** — creating and authorizing sync accounts requires
/// the account's private key. See [NotchPayClient.privateKey].
class NotchPaySyncAccount {
  /// Creates a sync account. Use [NotchPaySyncAccount.fromJson] to parse an
  /// API response instead.
  const NotchPaySyncAccount({
    required this.reference,
    this.callback,
    this.permissions = const [],
    this.raw = const {},
  });

  /// Parses a sync account from a decoded NotchPay API JSON response.
  factory NotchPaySyncAccount.fromJson(Map<String, dynamic> json) {
    final account = json['account'] is Map<String, dynamic>
        ? json['account'] as Map<String, dynamic>
        : json;
    return NotchPaySyncAccount(
      reference: (account['reference'] ?? account['id']) as String? ?? '',
      callback: account['callback'] as String?,
      permissions: account['permissions'] is Iterable
          ? (account['permissions'] as Iterable)
              .map((e) => '$e')
              .toList(growable: false)
          : const [],
      raw: json,
    );
  }

  /// Unique sub-account reference, e.g. `acc.test_SD9b2dwJ2nqX8XEclNpEcGGc`.
  final String reference;

  /// The URL the sub-account owner is redirected to after granting access.
  final String? callback;

  /// The scopes granted to this sub-account, e.g. `['payments', 'customers']`.
  final List<String> permissions;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;
}
