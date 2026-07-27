/// The result of an identity lookup or validation for a Mobile Money or
/// bank account number.
///
/// Used by the checkout UI to show the account owner's name before the
/// customer confirms a payment, reducing the risk of sending money to the
/// wrong recipient.
class NotchPayIdentity {
  /// Creates an identity result. Use [NotchPayIdentity.fromJson] to parse an
  /// API response instead.
  const NotchPayIdentity({
    required this.accountNumber,
    this.name,
    this.valid = false,
    this.raw = const {},
  });

  /// Parses an identity result from a decoded NotchPay API JSON response.
  factory NotchPayIdentity.fromJson(Map<String, dynamic> json) {
    return NotchPayIdentity(
      accountNumber: json['account_number'] as String? ?? '',
      name: (json['name'] ?? json['owner']) as String?,
      valid: json['valid'] as bool? ?? json['status'] == 'valid',
      raw: json,
    );
  }

  /// The account number that was looked up.
  final String accountNumber;

  /// The registered name of the account owner, when found.
  final String? name;

  /// Whether the account number is valid and active.
  final bool valid;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;
}
