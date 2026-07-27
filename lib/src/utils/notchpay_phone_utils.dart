import '../models/notchpay_channel.dart';

/// Utilities to recognize the Mobile Money operator behind a phone number,
/// so the checkout UI can highlight the right channel as the customer
/// types.
class NotchPayPhoneUtils {
  const NotchPayPhoneUtils._();

  static const _mtnCameroonPrefixes = [
    '650',
    '651',
    '652',
    '653',
    '654',
    '67',
    '680',
    '681',
    '682',
    '683',
    '684',
  ];

  static const _orangeCameroonPrefixes = [
    '655',
    '656',
    '657',
    '658',
    '659',
    '69',
    '685',
    '686',
    '687',
    '688',
    '689',
  ];

  /// Strips spaces, dashes and a leading `+237`/`237`/`0` from [phone],
  /// returning only the significant digits.
  static String normalize(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+237')) digits = digits.substring(4);
    if (digits.startsWith('237')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  /// Detects the Mobile Money operator for a Cameroonian phone number,
  /// returning [NotchPayChannelKind.mtn], [NotchPayChannelKind.orange] or
  /// [NotchPayChannelKind.mobileMoney] when the operator can't be
  /// determined yet (e.g. the number is still incomplete).
  static NotchPayChannelKind detectCameroonOperator(String phone) {
    final digits = normalize(phone);
    for (final prefix in _mtnCameroonPrefixes) {
      if (digits.startsWith(prefix)) return NotchPayChannelKind.mtn;
    }
    for (final prefix in _orangeCameroonPrefixes) {
      if (digits.startsWith(prefix)) return NotchPayChannelKind.orange;
    }
    return NotchPayChannelKind.mobileMoney;
  }

  /// Whether [phone] looks like a complete, valid Cameroonian mobile
  /// number (9 significant digits).
  static bool isValidCameroonMobile(String phone) {
    final digits = normalize(phone);
    return RegExp(r'^[6][0-9]{8}$').hasMatch(digits);
  }
}
