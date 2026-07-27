import '../client/notchpay_client.dart';
import '../models/notchpay_recipient.dart';

/// Manage transfer recipients / beneficiaries.
///
/// {@template notchpay.private_key_only}
/// **Backend use only.** Every method on this service requires the
/// account's private key (see [NotchPayClient.privateKey]) and must never be
/// called from code shipped inside a mobile application.
/// {@endtemplate}
class NotchPayRecipientService {
  /// Creates the service, using [client] for every request.
  const NotchPayRecipientService(this._client);

  final NotchPayClient _client;

  /// Lists saved recipients.
  ///
  /// {@macro notchpay.private_key_only}
  Future<List<NotchPayRecipient>> list() async {
    final json = await _client.get('/beneficiaries', requiresGrant: true);
    final items = json['beneficiaries'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayRecipient.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetches a single recipient by [reference].
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPayRecipient> fetch(String reference) async {
    final json =
        await _client.get('/beneficiaries/$reference', requiresGrant: true);
    final recipient = json['recipient'] ?? json['beneficiary'];
    return NotchPayRecipient.fromJson(
      recipient is Map<String, dynamic> ? recipient : json,
    );
  }

  /// Creates a new recipient.
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPayRecipient> create(NotchPayRecipient recipient) async {
    final json = await _client.post(
      '/recipients',
      body: recipient.toJson(),
      requiresGrant: true,
    );
    final created = json['recipient'] ?? json['beneficiary'];
    return NotchPayRecipient.fromJson(
      created is Map<String, dynamic> ? created : json,
    );
  }

  /// Deletes a recipient.
  ///
  /// {@macro notchpay.private_key_only}
  Future<void> delete(String reference) async {
    await _client.delete('/beneficiaries/$reference', requiresGrant: true);
  }
}
