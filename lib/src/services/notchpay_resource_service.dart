import '../client/notchpay_client.dart';
import '../models/notchpay_channel.dart';
import '../models/notchpay_country.dart';
import '../models/notchpay_currency.dart';

/// Read-only reference data: available payment channels, currencies and
/// countries.
class NotchPayResourceService {
  /// Creates the service, using [client] for every request.
  const NotchPayResourceService(this._client);

  final NotchPayClient _client;

  /// Lists the payment channels available, optionally filtered by
  /// [country] (ISO 3166-1 alpha-2, e.g. `cm`).
  Future<List<NotchPayChannel>> channels({String? country}) async {
    final json = await _client.get(
      '/channels',
      query: {'country': country},
    );
    final items = json['channels'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayChannel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Lists all currencies supported by NotchPay.
  Future<List<NotchPayCurrency>> currencies() async {
    final json = await _client.get('/currencies');
    final items = json['currencies'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayCurrency.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Lists all countries supported by NotchPay.
  Future<List<NotchPayCountry>> countries() async {
    final json = await _client.get('/countries');
    final items = json['countries'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayCountry.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
