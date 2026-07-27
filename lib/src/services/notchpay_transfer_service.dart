import '../client/notchpay_client.dart';
import '../models/notchpay_transfer.dart';

/// Send payouts to recipients.
///
/// {@macro notchpay.private_key_only}
class NotchPayTransferService {
  /// Creates the service, using [client] for every request.
  const NotchPayTransferService(this._client);

  final NotchPayClient _client;

  /// Initiates a transfer to a recipient described inline.
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPayTransfer> initiate({
    required double amount,
    required String currency,
    required String channel,
    required Map<String, dynamic> recipient,
    String? description,
    Map<String, dynamic> metadata = const {},
  }) async {
    final json = await _client.post(
      '/transfers',
      body: {
        'amount': '$amount',
        'currency': currency,
        'channel': channel,
        'recipient': recipient,
        'description': description,
        if (metadata.isNotEmpty) 'metadata': metadata,
      },
      requiresGrant: true,
    );
    final transfer = json['transfer'];
    return NotchPayTransfer.fromJson(
      transfer is Map<String, dynamic> ? transfer : json,
    );
  }

  /// Sends a transfer directly to an account without saving a recipient.
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPayTransfer> direct({
    required double amount,
    required String currency,
    required String channel,
    required String accountNumber,
    String? description,
    String? email,
  }) async {
    final json = await _client.post(
      '/transfers/direct',
      body: {
        'channel': channel,
        'currency': currency,
        'amount': '$amount',
        'beneficiary': {
          'account_number': accountNumber,
          if (email != null) 'email': email,
        },
        'description': description,
      },
      requiresGrant: true,
    );
    final transfer = json['transfer'];
    return NotchPayTransfer.fromJson(
      transfer is Map<String, dynamic> ? transfer : json,
    );
  }

  /// Lists transfers previously sent from this account.
  ///
  /// {@macro notchpay.private_key_only}
  Future<List<NotchPayTransfer>> list() async {
    final json = await _client.get('/transfers', requiresGrant: true);
    final items = json['transfers'] ?? json['data'] ?? const [];
    return (items as Iterable)
        .map((e) => NotchPayTransfer.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Fetches a single transfer by [reference].
  ///
  /// {@macro notchpay.private_key_only}
  Future<NotchPayTransfer> fetch(String reference) async {
    final json =
        await _client.get('/transfers/$reference', requiresGrant: true);
    final transfer = json['transfer'];
    return NotchPayTransfer.fromJson(
      transfer is Map<String, dynamic> ? transfer : json,
    );
  }
}
