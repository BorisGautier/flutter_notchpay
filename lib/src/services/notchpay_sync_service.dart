import '../client/notchpay_client.dart';
import '../models/notchpay_sync_account.dart';

/// Manage NotchPay Connect sub-accounts (platform / marketplace use cases).
///
/// {@macro notchpay.private_key_only}
class NotchPaySyncService {
  /// Creates the service, using [client] for every request.
  const NotchPaySyncService(this._client);

  final NotchPayClient _client;

  /// Lists sub-accounts.
  ///
  /// {@macro notchpay.private_key_only}
  Future<List<NotchPaySyncAccount>> list() async {
    final json = await _client.get('/accounts', requiresGrant: true);
    final items = json['accounts'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPaySyncAccount.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetches a single sub-account by [reference].
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPaySyncAccount> fetch(String reference) async {
    final json = await _client.get('/accounts/$reference', requiresGrant: true);
    return NotchPaySyncAccount.fromJson(json);
  }

  /// Creates a new sub-account requesting the given [permissions] (e.g.
  /// `['payments', 'customers']`).
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPaySyncAccount> initialize({
    required String callback,
    required List<String> permissions,
    required String profileName,
    required String profileEmail,
    String? email,
  }) async {
    final json = await _client.post(
      '/accounts',
      body: {
        'callback': callback,
        for (var i = 0; i < permissions.length; i++)
          'permissions[$i]': permissions[i],
        'profile[name]': profileName,
        'profile[email]': profileEmail,
        if (email != null) 'email': email,
      },
      requiresGrant: true,
    );
    return NotchPaySyncAccount.fromJson(json);
  }

  /// Exchanges a sub-account reference for its authorization / grant token.
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPaySyncAccount> authorize(String reference) async {
    final json =
        await _client.patch('/accounts/$reference', requiresGrant: true);
    return NotchPaySyncAccount.fromJson(json);
  }
}
