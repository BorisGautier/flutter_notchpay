import 'notchpay_payment_status.dart';

/// A payout / transfer (`trf.xxx`) sent from a NotchPay account to a
/// recipient.
///
/// **Backend use only** — initiating and listing transfers requires the
/// account's private key. See [NotchPayClient.privateKey].
class NotchPayTransfer {
  /// Creates a transfer. Use [NotchPayTransfer.fromJson] to parse an API
  /// response instead.
  const NotchPayTransfer({
    required this.reference,
    required this.amount,
    required this.currency,
    this.description,
    this.channel,
    this.status = NotchPayPaymentStatus.unknown,
    this.metadata = const {},
    this.raw = const {},
  });

  /// Parses a transfer from a decoded NotchPay API JSON response.
  factory NotchPayTransfer.fromJson(Map<String, dynamic> json) {
    return NotchPayTransfer(
      reference: (json['reference'] ?? json['id']) as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
      description: json['description'] as String?,
      channel: json['channel'] as String?,
      status: NotchPayPaymentStatus.parse(json['status'] as String?),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : const {},
      raw: json,
    );
  }

  /// Unique transfer reference, e.g. `trf.bgPoV48Eh2VEGUNIbicOOJ27d08rCnfv`.
  final String reference;

  /// The amount sent, in the currency's major unit.
  final double amount;

  /// ISO 4217 currency code, e.g. `XAF`.
  final String currency;

  /// A short description of this transfer.
  final String? description;

  /// The payout channel used, e.g. `cm.mobile`.
  final String? channel;

  /// Current lifecycle status of the transfer.
  final NotchPayPaymentStatus status;

  /// Free-form metadata attached to the transfer.
  final Map<String, dynamic> metadata;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;
}
