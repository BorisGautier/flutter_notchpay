import '../client/notchpay_client.dart';
import '../models/notchpay_refund.dart';

/// Read refunds issued for NotchPay transactions.
///
/// {@macro notchpay.private_key_only}
class NotchPayRefundService {
  /// Creates the service, using [client] for every request.
  const NotchPayRefundService(this._client);

  final NotchPayClient _client;

  /// Lists refunds.
  ///
  /// {@macro notchpay.private_key_only}
  Future<List<NotchPayRefund>> list() async {
    final json = await _client.get('/refunds', requiresGrant: true);
    final items = json['refunds'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayRefund.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetches a single refund by [reference].
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPayRefund> fetch(String reference) async {
    final json = await _client.get('/refunds/$reference', requiresGrant: true);
    final refund = json['refund'];
    return NotchPayRefund.fromJson(
      refund is Map<String, dynamic> ? refund : json,
    );
  }
}
