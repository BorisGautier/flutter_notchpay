import 'notchpay_payment_status.dart';

/// A refund issued for a NotchPay transaction.
///
/// **Backend use only** — listing and fetching refunds requires the
/// account's private key. See [NotchPayClient.privateKey].
class NotchPayRefund {
  /// Creates a refund. Use [NotchPayRefund.fromJson] to parse an API
  /// response instead.
  const NotchPayRefund({
    required this.reference,
    required this.amount,
    this.currency,
    this.transaction,
    this.reason,
    this.status = NotchPayPaymentStatus.unknown,
    this.raw = const {},
  });

  /// Parses a refund from a decoded NotchPay API JSON response.
  factory NotchPayRefund.fromJson(Map<String, dynamic> json) {
    return NotchPayRefund(
      reference: (json['reference'] ?? json['id']) as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String?,
      transaction: json['transaction'] as String?,
      reason: json['reason'] as String?,
      status: NotchPayPaymentStatus.parse(json['status'] as String?),
      raw: json,
    );
  }

  /// Unique refund reference.
  final String reference;

  /// The refunded amount, in the currency's major unit.
  final double amount;

  /// ISO 4217 currency code, e.g. `XAF`.
  final String? currency;

  /// The reference of the transaction this refund applies to.
  final String? transaction;

  /// The reason given for this refund, if any.
  final String? reason;

  /// Current lifecycle status of the refund.
  final NotchPayPaymentStatus status;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;
}
