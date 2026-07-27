import '../client/notchpay_client.dart';
import '../models/notchpay_balance.dart';

/// Read a NotchPay account's balance.
///
/// {@macro notchpay.private_key_only}
class NotchPayBalanceService {
  /// Creates the service, using [client] for every request.
  const NotchPayBalanceService(this._client);

  final NotchPayClient _client;

  /// Fetches the balance for every currency held by the account.
  ///
  /// {@macro notchpay.private_key_only}
  Future<List<NotchPayBalance>> fetch() async {
    final json = await _client.get('/balance', requiresGrant: true);
    final items =
        json['balance'] ?? json['balances'] ?? json['data'] ?? const [];
    if (items is Map<String, dynamic>) {
      return [NotchPayBalance.fromJson(items)];
    }
    return (items as Iterable)
        .map((e) => NotchPayBalance.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
