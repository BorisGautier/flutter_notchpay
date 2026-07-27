/// A currency supported by NotchPay, as returned by `GET /currencies`.
class NotchPayCurrency {
  /// Creates a currency. Use [NotchPayCurrency.fromJson] to parse an API
  /// response instead.
  const NotchPayCurrency({
    required this.code,
    this.name,
    this.symbol,
    this.decimals = 0,
  });

  /// Parses a currency from a decoded NotchPay API JSON response.
  factory NotchPayCurrency.fromJson(Map<String, dynamic> json) {
    return NotchPayCurrency(
      code: (json['code'] ?? json['iso'] ?? '') as String,
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      decimals: (json['decimals'] as num?)?.toInt() ?? 0,
    );
  }

  /// ISO 4217 currency code, e.g. `XAF`.
  final String code;

  /// The currency's display name, e.g. `CFA Franc BEAC`.
  final String? name;

  /// The currency's symbol, e.g. `FCFA`.
  final String? symbol;

  /// Number of decimal digits used by this currency (`0` for `XAF`/`XOF`).
  final int decimals;

  @override
  String toString() => 'NotchPayCurrency($code)';
}
