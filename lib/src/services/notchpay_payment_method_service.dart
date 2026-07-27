import '../client/notchpay_client.dart';
import '../models/notchpay_payment_method.dart';

/// Manage saved payment methods.
class NotchPayPaymentMethodService {
  /// Creates the service, using [client] for every request.
  const NotchPayPaymentMethodService(this._client);

  final NotchPayClient _client;

  /// Lists saved payment methods.
  Future<List<NotchPayPaymentMethod>> list() async {
    final json = await _client.get('/payment_methods');
    final items = json['payment_methods'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayPaymentMethod.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetches a single payment method by [reference].
  Future<NotchPayPaymentMethod> fetch(String reference) async {
    final json = await _client.get('/payment-methods/$reference');
    final method = json['payment_method'];
    return NotchPayPaymentMethod.fromJson(
      method is Map<String, dynamic> ? method : json,
    );
  }
}
