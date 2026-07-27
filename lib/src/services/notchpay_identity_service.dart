import '../client/notchpay_client.dart';
import '../models/notchpay_identity.dart';

/// Look up and validate Mobile Money / bank account identities.
///
/// Useful right before completing a payment: show the customer the
/// registered owner name of the account they are about to pay from, so they
/// can catch typos before money moves.
class NotchPayIdentityService {
  /// Creates the service, using [client] for every request.
  const NotchPayIdentityService(this._client);

  final NotchPayClient _client;

  /// Looks up the owner of an account number.
  Future<NotchPayIdentity> fetch({
    required String accountNumber,
    required String country,
    required String type,
  }) async {
    final json = await _client.post(
      '/identity',
      body: {
        'account_number': accountNumber,
        'country': country,
        'type': type,
      },
    );
    return NotchPayIdentity.fromJson(json);
  }

  /// Validates that [name] matches the registered owner of an account
  /// number.
  Future<NotchPayIdentity> validate({
    required String accountNumber,
    required String country,
    required String type,
    String? name,
  }) async {
    final json = await _client.post(
      '/identity/validate',
      body: {
        'account_number': accountNumber,
        'country': country,
        'type': type,
        if (name != null) 'name': name,
      },
    );
    return NotchPayIdentity.fromJson(json);
  }
}
