import 'notchpay_customer.dart';
import 'notchpay_payment_status.dart';

/// A NotchPay transaction (`trx.xxx`), as created by `POST /payments`.
///
/// See https://developers.notchpay.co/api/payment
class NotchPayPayment {
  /// Creates a transaction. Use [NotchPayPayment.fromJson] to parse an API
  /// response instead.
  const NotchPayPayment({
    required this.reference,
    required this.amount,
    required this.currency,
    this.fee,
    this.description,
    this.status = NotchPayPaymentStatus.unknown,
    this.customer,
    this.channel,
    this.authorizationUrl,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.raw = const {},
  });

  /// Parses a transaction from a decoded NotchPay API JSON response. Accepts
  /// both a flat payload and one wrapped in a `transaction` key.
  factory NotchPayPayment.fromJson(Map<String, dynamic> json) {
    final transaction = json['transaction'] is Map<String, dynamic>
        ? json['transaction'] as Map<String, dynamic>
        : json;
    return NotchPayPayment(
      reference: (transaction['reference'] ?? transaction['trx_reference'])
              as String? ??
          '',
      amount: (transaction['amount'] as num?)?.toDouble() ?? 0,
      currency: transaction['currency'] as String? ?? '',
      fee: (transaction['fee'] as num?)?.toDouble(),
      description: transaction['description'] as String?,
      status: NotchPayPaymentStatus.parse(transaction['status'] as String?),
      customer: transaction['customer'] is Map<String, dynamic>
          ? NotchPayCustomer.fromJson(
              transaction['customer'] as Map<String, dynamic>)
          : null,
      channel: transaction['channel'] as String?,
      authorizationUrl: (transaction['authorization_url'] ??
          json['authorization_url']) as String?,
      metadata: transaction['metadata'] is Map<String, dynamic>
          ? transaction['metadata'] as Map<String, dynamic>
          : const {},
      createdAt: DateTime.tryParse('${transaction['created_at']}'),
      updatedAt: DateTime.tryParse('${transaction['updated_at']}'),
      raw: json,
    );
  }

  /// Unique transaction reference, e.g. `trx.RoOvUhfZXi79G7ZrAkL3JUBt`.
  final String reference;

  /// The amount to be paid, in the currency's major unit.
  final double amount;

  /// ISO 4217 currency code, e.g. `XAF`.
  final String currency;

  /// Fees charged by NotchPay for this transaction, if known yet.
  final double? fee;

  /// A short description of this transaction.
  final String? description;

  /// Current lifecycle status of the transaction.
  final NotchPayPaymentStatus status;

  /// The paying customer, when known.
  final NotchPayCustomer? customer;

  /// The payment channel used to complete this transaction (e.g. `cm.mtn`),
  /// once known.
  final String? channel;

  /// A URL the customer can be redirected to in order to finish the
  /// payment (used as a fallback for channels this package's UI does not
  /// render natively, e.g. some card 3-D Secure flows).
  final String? authorizationUrl;

  /// Free-form metadata attached to the transaction.
  final Map<String, dynamic> metadata;

  /// When this transaction was created.
  final DateTime? createdAt;

  /// When this transaction was last updated.
  final DateTime? updatedAt;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;

  /// A human-readable message or reason returned by the API for this payment,
  /// if present.
  String? get message {
    final rawMsg = raw['message'] ??
        raw['reason'] ??
        raw['status_reason'] ??
        raw['error'];
    if (rawMsg is String && rawMsg.trim().isNotEmpty) return rawMsg.trim();
    final trx = raw['transaction'];
    if (trx is Map<String, dynamic>) {
      final trxMsg = trx['message'] ??
          trx['reason'] ??
          trx['status_reason'] ??
          trx['error'];
      if (trxMsg is String && trxMsg.trim().isNotEmpty) return trxMsg.trim();
    }
    return null;
  }

  @override
  String toString() =>
      'NotchPayPayment($reference, $amount $currency, $status)';
}
