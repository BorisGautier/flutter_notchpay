/// The broad family a [NotchPayChannel] belongs to.
///
/// Used by the checkout UI to pick an icon, a color and the right input
/// form (phone number vs. card fields) for a channel.
enum NotchPayChannelKind {
  /// MTN Mobile Money.
  mtn,

  /// Orange Money.
  orange,

  /// YooMee Money.
  yoomee,

  /// Generic mobile money channel (operator picked automatically).
  mobileMoney,

  /// Visa / Mastercard payments.
  card,

  /// Bank transfer / USSD.
  bank,

  /// Anything not recognized above.
  other;

  /// Infers a [NotchPayChannelKind] from a NotchPay channel code/slug or name.
  static NotchPayChannelKind fromCode(String code, [String? name]) {
    final normalized = '${code.toLowerCase()} ${name?.toLowerCase() ?? ''}';
    if (normalized.contains('mtn') || normalized.contains('momo')) {
      return NotchPayChannelKind.mtn;
    }
    if (normalized.contains('yoomee')) {
      return NotchPayChannelKind.yoomee;
    }
    if (normalized.contains('orange') || RegExp(r'\bom\b').hasMatch(normalized)) {
      return NotchPayChannelKind.orange;
    }
    if (normalized.contains('card') ||
        normalized.contains('carte') ||
        normalized.contains('visa') ||
        normalized.contains('mastercard')) {
      return NotchPayChannelKind.card;
    }
    if (normalized.contains('bank') || normalized.contains('ussd')) {
      return NotchPayChannelKind.bank;
    }
    if (normalized.contains('mobile') || normalized.contains('wallet')) {
      return NotchPayChannelKind.mobileMoney;
    }
    return NotchPayChannelKind.other;
  }
}

/// A payment channel supported by NotchPay (e.g. MTN Mobile Money, Orange
/// Money, or Card), as returned by `GET /channels`.
class NotchPayChannel {
  /// Creates a channel. Use [NotchPayChannel.fromJson] to parse an API
  /// response instead.
  const NotchPayChannel({
    required this.code,
    required this.name,
    this.countries = const [],
    this.currencies = const [],
    this.raw = const {},
  });

  /// Parses a channel from a decoded NotchPay API JSON response.
  factory NotchPayChannel.fromJson(Map<String, dynamic> json) {
    final rawCurrencies = json['currencies'] ??
        (json['currency'] != null ? [json['currency']] : null);
    return NotchPayChannel(
      code: (json['code'] ?? json['id'] ?? json['slug'] ?? json['channel'] ?? '')
          as String,
      name: (json['name'] ?? json['label'] ?? '') as String,
      countries: _stringList(json['countries']),
      currencies: _stringList(rawCurrencies),
      raw: json,
    );
  }

  /// The channel identifier used everywhere else in the API, e.g. `cm.mtn`.
  final String code;

  /// A human friendly display name, e.g. `MTN Mobile Money`.
  final String name;

  /// ISO country codes this channel is available in.
  final List<String> countries;

  /// Currency codes this channel can settle in.
  final List<String> currencies;

  /// The untouched JSON payload returned by the API, for advanced use cases.
  final Map<String, dynamic> raw;

  /// The broad family this channel belongs to, used to pick UI treatment.
  NotchPayChannelKind get kind => NotchPayChannelKind.fromCode(code, name);

  static List<String> _stringList(Object? value) {
    if (value is Iterable) {
      return value.map((e) => '$e').toList(growable: false);
    }
    return const [];
  }

  @override
  String toString() => 'NotchPayChannel($code, $name)';
}
