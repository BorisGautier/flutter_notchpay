import '../models/notchpay_channel.dart';

/// Utilities to recognize the Mobile Money operator behind a phone number,
/// so the checkout UI can highlight the right channel as the customer
/// types.
class NotchPayPhoneUtils {
  const NotchPayPhoneUtils._();

  static const Map<String, NotchPayChannelKind> _prefixMap = {
    // Cameroon (CM)
    '+23767': NotchPayChannelKind.mtn,
    '+23769': NotchPayChannelKind.orange,
    '+23768': NotchPayChannelKind.eumm,
    '+23766': NotchPayChannelKind.yoomee,

    // Ivory Coast (CI)
    '+22505': NotchPayChannelKind.mtn,
    '+22507': NotchPayChannelKind.orange,
    '+22501': NotchPayChannelKind.moov,
    '+22503': NotchPayChannelKind.wave,

    // Nigeria (NG)
    '+2348': NotchPayChannelKind.mtn,
    '+2347': NotchPayChannelKind.orange,

    // Senegal (SN)
    '+22177': NotchPayChannelKind.orange,
    '+22176': NotchPayChannelKind.free,

    // Gabon (GA)
    '+2410': NotchPayChannelKind.airtel,
    '+2411': NotchPayChannelKind.eumm,

    // Benin (BJ)
    '+22990': NotchPayChannelKind.mtn,
    '+22991': NotchPayChannelKind.moov,
    '+22997': NotchPayChannelKind.glo,

    // Burkina Faso (BF)
    '+22670': NotchPayChannelKind.orange,
    '+22671': NotchPayChannelKind.moov,

    // Uganda (UG)
    '+25677': NotchPayChannelKind.mtn,
    '+25675': NotchPayChannelKind.airtel,

    // Rwanda (RW)
    '+25078': NotchPayChannelKind.mtn,
    '+25073': NotchPayChannelKind.airtel,

    // DR Congo (CD)
    '+24399': NotchPayChannelKind.airtel,
    '+24389': NotchPayChannelKind.orange,
    '+24381': NotchPayChannelKind.vodafone,
    '+24382': NotchPayChannelKind.eumm,

    // Tanzania (TZ)
    '+25567': NotchPayChannelKind.airtel,
    '+25565': NotchPayChannelKind.tigo,
    '+25574': NotchPayChannelKind.vodafone,
    '+25562': NotchPayChannelKind.halopesa,

    // Kenya (KE)
    '+25470': NotchPayChannelKind.mpesa,
    '+25471': NotchPayChannelKind.mpesa,
    '+25473': NotchPayChannelKind.airtel,
    '+25476': NotchPayChannelKind.equitel,
    '+25477': NotchPayChannelKind.tkash,

    // Ghana (GH)
    '+23324': NotchPayChannelKind.mtn,
    '+23320': NotchPayChannelKind.vodafone,
    '+23326': NotchPayChannelKind.airtel,
    '+23327': NotchPayChannelKind.airtel,

    // Chad (TD)
    '+23566': NotchPayChannelKind.eumm,

    // Central African Republic (CF)
    '+23670': NotchPayChannelKind.eumm,

    // Congo Brazzaville (CG)
    '+24205': NotchPayChannelKind.eumm,
  };

  /// Strips spaces, dashes and a leading `+237`/`237`/`0` from [phone],
  /// returning only the significant digits.
  static String normalize(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+237')) digits = digits.substring(4);
    if (digits.startsWith('237')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits;
  }

  /// Detects the operator kind by inspecting international or local prefixes.
  static NotchPayChannelKind detectOperator(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!cleaned.startsWith('+')) {
      final cameroonKind = detectCameroonOperator(cleaned);
      if (cameroonKind != NotchPayChannelKind.mobileMoney) return cameroonKind;
    }

    for (final entry in _prefixMap.entries) {
      if (cleaned.startsWith(entry.key)) return entry.value;
    }
    return NotchPayChannelKind.mobileMoney;
  }

  /// Detects Cameroonian operators for local numbers.
  static NotchPayChannelKind detectCameroonOperator(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('237')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);

    if (digits.startsWith('67') ||
        digits.startsWith('650') ||
        digits.startsWith('651') ||
        digits.startsWith('652') ||
        digits.startsWith('653') ||
        digits.startsWith('654') ||
        digits.startsWith('680') ||
        digits.startsWith('681') ||
        digits.startsWith('682') ||
        digits.startsWith('683') ||
        digits.startsWith('684')) {
      return NotchPayChannelKind.mtn;
    }

    if (digits.startsWith('69') ||
        digits.startsWith('655') ||
        digits.startsWith('656') ||
        digits.startsWith('657') ||
        digits.startsWith('658') ||
        digits.startsWith('659') ||
        digits.startsWith('685') ||
        digits.startsWith('686') ||
        digits.startsWith('687') ||
        digits.startsWith('688') ||
        digits.startsWith('689')) {
      return NotchPayChannelKind.orange;
    }

    if (digits.startsWith('66')) return NotchPayChannelKind.yoomee;
    if (digits.startsWith('68')) return NotchPayChannelKind.eumm;

    return NotchPayChannelKind.mobileMoney;
  }

  /// Whether [phone] looks like a valid Cameroonian mobile number.
  static bool isValidCameroonMobile(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('237')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return RegExp(r'^[6][0-9]{8}$').hasMatch(digits);
  }
}
