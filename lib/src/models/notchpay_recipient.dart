/// A transfer recipient / beneficiary (`bn.xxx`) saved on a NotchPay
/// account.
///
/// **Backend use only** — creating and listing recipients requires the
/// account's private key. See [NotchPayClient.privateKey].
class NotchPayRecipient {
  /// Creates a recipient. Use [NotchPayRecipient.fromJson] to parse an API
  /// response instead.
  const NotchPayRecipient({
    required this.reference,
    required this.name,
    this.country,
    this.currency,
    this.channel,
    this.accountNumber,
    this.phone,
    this.raw = const {},
  });

  /// Parses a recipient from a decoded NotchPay API JSON response.
  factory NotchPayRecipient.fromJson(Map<String, dynamic> json) {
    return NotchPayRecipient(
      reference: (json['reference'] ?? json['id']) as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      channel: json['channel'] as String?,
      accountNumber: json['account_number'] as String?,
      phone: json['phone'] as String?,
      raw: json,
    );
  }

  /// Unique recipient reference, e.g. `bn.ez4tFl9qTF94XaQy`.
  final String reference;

  /// The recipient's full name.
  final String name;

  /// ISO 3166-1 alpha-2 country code, e.g. `CM`.
  final String? country;

  /// ISO 4217 currency code, e.g. `XAF`.
  final String? currency;

  /// The payout channel to use for this recipient, e.g. `cm.mobile`.
  final String? channel;

  /// The recipient's Mobile Money or bank account number.
  final String? accountNumber;

  /// The recipient's phone number, when required by [channel].
  final String? phone;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;

  /// Serializes this recipient into the payload expected by the create
  /// recipient endpoint.
  Map<String, dynamic> toJson() => {
        'name': name,
        if (country != null) 'country': country,
        if (currency != null) 'currency': currency,
        if (channel != null) 'channel': channel,
        if (accountNumber != null) 'account_number': accountNumber,
        if (phone != null) 'phone': phone,
      };
}
