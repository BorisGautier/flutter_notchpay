import '../client/notchpay_client.dart';
import '../models/notchpay_checkout_request.dart';
import '../models/notchpay_payment.dart';
import '../models/notchpay_payment_status.dart';

/// Create and manage NotchPay transactions.
///
/// See https://developers.notchpay.co/api/payment
class NotchPayPaymentService {
  /// Creates the service, using [client] for every request.
  const NotchPayPaymentService(this._client);

  final NotchPayClient _client;

  /// Initializes a new transaction. This is always the first step of a
  /// payment: it returns a [NotchPayPayment.reference] you then submit a
  /// channel for with [complete].
  Future<NotchPayPayment> initialize(NotchPayCheckoutRequest request) async {
    final json = await _client.post('/payments', body: request.toJson());
    return NotchPayPayment.fromJson(json);
  }

  /// Fetches the current state of a transaction by [reference].
  Future<NotchPayPayment> fetch(String reference) async {
    final json = await _client.get('/payments/$reference');
    return NotchPayPayment.fromJson(json);
  }

  /// Lists transactions, optionally filtered by [status] or [channels].
  Future<List<NotchPayPayment>> list({
    NotchPayPaymentStatus? status,
    List<String>? channels,
    int? limit,
    int? page,
  }) async {
    final json = await _client.get(
      '/payments',
      query: {
        'status': status?.name,
        'channels': channels,
        'limit': limit,
        'page': page,
      },
    );
    final items = json['transactions'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayPayment.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Submits the payment [channel] (e.g. `cm.mtn`, `cm.orange`, `card`) and
  /// its [data] (e.g. `{'phone': '+237655728267'}`) to complete a
  /// transaction previously created with [initialize].
  Future<NotchPayPayment> complete(
    String reference, {
    required String channel,
    Map<String, dynamic> data = const {},
  }) async {
    final json = await _client.post(
      '/payments/$reference',
      body: {'channel': channel, 'data': data},
    );
    return NotchPayPayment.fromJson(json);
  }

  /// Cancels a pending transaction.
  Future<void> cancel(String reference) async {
    await _client.delete('/payments/$reference');
  }
}
