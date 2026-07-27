import '../client/notchpay_client.dart';
import '../models/notchpay_address.dart';
import '../models/notchpay_customer.dart';

/// Manage NotchPay customers.
///
/// See https://developers.notchpay.co/api/customer
class NotchPayCustomerService {
  /// Creates the service, using [client] for every request.
  const NotchPayCustomerService(this._client);

  final NotchPayClient _client;

  /// Creates a new customer.
  Future<NotchPayCustomer> create({
    required String name,
    String? email,
    String? phone,
    String? description,
    NotchPayAddress? address,
    NotchPayAddress? shipping,
  }) async {
    final json = await _client.post(
      '/customers',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
        if (address != null) 'address': address.toJson(),
        if (shipping != null) 'shipping': shipping.toJson(),
      },
    );
    return NotchPayCustomer.fromJson(_unwrap(json));
  }

  /// Lists customers, [page] by [limit].
  Future<List<NotchPayCustomer>> list({int? limit, int? page}) async {
    final json = await _client.get(
      '/customers',
      query: {'limit': limit, 'page': page},
    );
    final items = json['customers'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayCustomer.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetches a single customer by [reference].
  Future<NotchPayCustomer> fetch(String reference) async {
    final json = await _client.get('/customers/$reference');
    return NotchPayCustomer.fromJson(_unwrap(json));
  }

  /// Updates an existing customer.
  Future<NotchPayCustomer> update(
    String reference, {
    String? name,
    String? email,
    String? phone,
    String? description,
    NotchPayAddress? address,
    NotchPayAddress? shipping,
  }) async {
    final json = await _client.post(
      '/customers/$reference',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
        if (address != null) 'address': address.toJson(),
        if (shipping != null) 'shipping': shipping.toJson(),
      },
    );
    return NotchPayCustomer.fromJson(_unwrap(json));
  }

  /// Blocks a customer, preventing them from paying again.
  Future<void> block(String reference) async {
    await _client.post('/customers/$reference/block');
  }

  /// Unblocks a previously blocked customer.
  Future<void> unblock(String reference) async {
    await _client.patch('/customers/$reference/unblock');
  }

  /// Permanently deletes a customer.
  Future<void> delete(String reference) async {
    await _client.delete('/customers/$reference');
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final customer = json['customer'];
    return customer is Map<String, dynamic> ? customer : json;
  }
}
