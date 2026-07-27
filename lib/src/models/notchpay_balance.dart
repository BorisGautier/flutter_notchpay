/// The available and pending balance of a NotchPay account for a given
/// currency.
///
/// **Backend use only** — fetching the balance requires the account's
/// private key. See [NotchPayClient.privateKey].
class NotchPayBalance {
  /// Creates a balance snapshot. Use [NotchPayBalance.fromJson] to parse an
  /// API response instead.
  const NotchPayBalance({
    required this.currency,
    required this.available,
    required this.pending,
  });

  /// Parses a balance from a decoded NotchPay API JSON response.
  factory NotchPayBalance.fromJson(Map<String, dynamic> json) {
    return NotchPayBalance(
      currency: json['currency'] as String? ?? '',
      available: (json['available'] as num?)?.toDouble() ?? 0,
      pending: (json['pending'] as num?)?.toDouble() ?? 0,
    );
  }

  /// ISO 4217 currency code, e.g. `XAF`.
  final String currency;

  /// Funds that can be withdrawn or transferred right now.
  final double available;

  /// Funds that are still settling and not yet available.
  final double pending;
}
