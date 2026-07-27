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

  /// Moov Money.
  moov,

  /// Wave Mobile Money.
  wave,

  /// Airtel Money / AirtelTigo.
  airtel,

  /// Vodafone / Vodacom.
  vodafone,

  /// Safaricom M-Pesa.
  mpesa,

  /// Free Mobile Money Senegal.
  free,

  /// Express Union / EU Mobile.
  eumm,

  /// Glo Mobile.
  glo,

  /// Tigo Pesa.
  tigo,

  /// HaloPesa.
  halopesa,

  /// Equitel.
  equitel,

  /// Telkom Tkash.
  tkash,

  /// Green Network Côte d'Ivoire.
  green,

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
    if (normalized.contains('yoomee')) {
      return NotchPayChannelKind.yoomee;
    }
    if (normalized.contains('mtn') || normalized.contains('momo')) {
      return NotchPayChannelKind.mtn;
    }
    if (normalized.contains('orange') ||
        RegExp(r'\bom\b').hasMatch(normalized)) {
      return NotchPayChannelKind.orange;
    }
    if (normalized.contains('moov')) {
      return NotchPayChannelKind.moov;
    }
    if (normalized.contains('wave')) {
      return NotchPayChannelKind.wave;
    }
    if (normalized.contains('airtel')) {
      return NotchPayChannelKind.airtel;
    }
    if (normalized.contains('vodafone') || normalized.contains('vodacom')) {
      return NotchPayChannelKind.vodafone;
    }
    if (normalized.contains('mpesa') || normalized.contains('m-pesa')) {
      return NotchPayChannelKind.mpesa;
    }
    if (normalized.contains('free')) {
      return NotchPayChannelKind.free;
    }
    if (normalized.contains('express') ||
        normalized.contains('eu') ||
        normalized.contains('eumm')) {
      return NotchPayChannelKind.eumm;
    }
    if (normalized.contains('glo')) {
      return NotchPayChannelKind.glo;
    }
    if (normalized.contains('tigo')) {
      return NotchPayChannelKind.tigo;
    }
    if (normalized.contains('halopesa') || normalized.contains('halo')) {
      return NotchPayChannelKind.halopesa;
    }
    if (normalized.contains('equitel')) {
      return NotchPayChannelKind.equitel;
    }
    if (normalized.contains('tkash') || normalized.contains('telkom')) {
      return NotchPayChannelKind.tkash;
    }
    if (normalized.contains('green')) {
      return NotchPayChannelKind.green;
    }
    if (normalized.contains('card') ||
        normalized.contains('carte') ||
        normalized.contains('visa') ||
        normalized.contains('mastercard')) {
      return NotchPayChannelKind.card;
    }
    if (normalized.contains('bank') ||
        normalized.contains('banque') ||
        normalized.contains('transfer') ||
        normalized.contains('virement') ||
        normalized.contains('ussd')) {
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
      code: (json['code'] ??
          json['id'] ??
          json['slug'] ??
          json['channel'] ??
          '') as String,
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
