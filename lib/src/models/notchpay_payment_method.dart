/// A saved payment method on a NotchPay account, as returned by
/// `GET /payment_methods`.
class NotchPayPaymentMethod {
  /// Creates a payment method. Use [NotchPayPaymentMethod.fromJson] to parse
  /// an API response instead.
  const NotchPayPaymentMethod({
    required this.reference,
    required this.type,
    this.brand,
    this.last4,
    this.raw = const {},
  });

  /// Parses a payment method from a decoded NotchPay API JSON response.
  factory NotchPayPaymentMethod.fromJson(Map<String, dynamic> json) {
    return NotchPayPaymentMethod(
      reference: (json['reference'] ?? json['id']) as String? ?? '',
      type: json['type'] as String? ?? '',
      brand: json['brand'] as String?,
      last4: json['last4'] as String?,
      raw: json,
    );
  }

  /// Unique payment method reference.
  final String reference;

  /// The payment method type, e.g. `card`.
  final String type;

  /// The card brand, when [type] is `card` (e.g. `visa`).
  final String? brand;

  /// The last 4 digits of the underlying card or account, when available.
  final String? last4;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;
}
