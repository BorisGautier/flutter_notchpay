/// A country supported by NotchPay, as returned by `GET /countries`.
class NotchPayCountry {
  /// Creates a country. Use [NotchPayCountry.fromJson] to parse an API
  /// response instead.
  const NotchPayCountry({
    required this.code,
    this.name,
    this.currency,
    this.dialCode,
    this.flag,
  });

  /// Parses a country from a decoded NotchPay API JSON response.
  factory NotchPayCountry.fromJson(Map<String, dynamic> json) {
    return NotchPayCountry(
      code: (json['code'] ?? json['iso'] ?? '') as String,
      name: json['name'] as String?,
      currency: json['currency'] as String?,
      dialCode: (json['dial_code'] ?? json['phone_code']) as String?,
      flag: json['flag'] as String?,
    );
  }

  /// ISO 3166-1 alpha-2 country code, e.g. `CM`.
  final String code;

  /// The country's display name.
  final String? name;

  /// The default currency for this country, e.g. `XAF`.
  final String? currency;

  /// International dialing code, e.g. `+237`.
  final String? dialCode;

  /// A URL or emoji representing the country's flag, when provided by the
  /// API.
  final String? flag;

  @override
  String toString() => 'NotchPayCountry($code)';
}
