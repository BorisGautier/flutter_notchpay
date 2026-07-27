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

  /// Detects the ISO 3166-1 alpha-2 country code (e.g. 'CM', 'CI', 'NG')
  /// from an international phone number string.
  static String? detectCountryCode(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+237') || cleaned.startsWith('237')) return 'CM';
    if (cleaned.startsWith('+225') || cleaned.startsWith('225')) return 'CI';
    if (cleaned.startsWith('+234') || cleaned.startsWith('234')) return 'NG';
    if (cleaned.startsWith('+221') || cleaned.startsWith('221')) return 'SN';
    if (cleaned.startsWith('+241') || cleaned.startsWith('241')) return 'GA';
    if (cleaned.startsWith('+229') || cleaned.startsWith('229')) return 'BJ';
    if (cleaned.startsWith('+226') || cleaned.startsWith('226')) return 'BF';
    if (cleaned.startsWith('+256') || cleaned.startsWith('256')) return 'UG';
    if (cleaned.startsWith('+250') || cleaned.startsWith('250')) return 'RW';
    if (cleaned.startsWith('+243') || cleaned.startsWith('243')) return 'CD';
    if (cleaned.startsWith('+255') || cleaned.startsWith('255')) return 'TZ';
    if (cleaned.startsWith('+254') || cleaned.startsWith('254')) return 'KE';
    if (cleaned.startsWith('+233') || cleaned.startsWith('233')) return 'GH';
    if (cleaned.startsWith('+235') || cleaned.startsWith('235')) return 'TD';
    if (cleaned.startsWith('+236') || cleaned.startsWith('236')) return 'CF';
    if (cleaned.startsWith('+242') || cleaned.startsWith('242')) return 'CG';
    return null;
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

  /// Returns the expected phone number format hint for a given operator [kind]
  /// and [countryCode] (e.g. `+237 670 000 000` or `+225 050 000 0000`).
  static String getPhoneHint(NotchPayChannelKind kind, {String? countryCode}) {
    final country = countryCode?.toLowerCase() ?? 'cm';
    switch (country) {
      case 'ci':
        return switch (kind) {
          NotchPayChannelKind.mtn => '+225 050 000 0000',
          NotchPayChannelKind.orange => '+225 070 000 0000',
          NotchPayChannelKind.moov => '+225 010 000 0000',
          NotchPayChannelKind.wave => '+225 030 000 0000',
          NotchPayChannelKind.green => '+225 090 000 0000',
          _ => '+225 050 000 0000',
        };
      case 'ng':
        return switch (kind) {
          NotchPayChannelKind.orange => '+234 700 000 0000',
          _ => '+234 800 000 0000',
        };
      case 'sn':
        return switch (kind) {
          NotchPayChannelKind.free => '+221 76 000 00 00',
          _ => '+221 77 000 00 00',
        };
      case 'ga':
        return switch (kind) {
          NotchPayChannelKind.eumm => '+241 11 00 00 00',
          _ => '+241 07 00 00 00',
        };
      case 'bj':
        return switch (kind) {
          NotchPayChannelKind.moov => '+229 91 00 00 00',
          NotchPayChannelKind.glo => '+229 97 00 00 00',
          _ => '+229 90 00 00 00',
        };
      case 'bf':
        return switch (kind) {
          NotchPayChannelKind.moov => '+226 71 00 00 00',
          _ => '+226 70 00 00 00',
        };
      case 'ug':
        return switch (kind) {
          NotchPayChannelKind.airtel => '+256 750 000 000',
          _ => '+256 770 000 000',
        };
      case 'rw':
        return switch (kind) {
          NotchPayChannelKind.airtel => '+250 730 000 000',
          _ => '+250 780 000 000',
        };
      case 'cd':
        return switch (kind) {
          NotchPayChannelKind.orange => '+243 890 000 000',
          NotchPayChannelKind.vodafone => '+243 810 000 000',
          NotchPayChannelKind.eumm => '+243 820 000 000',
          _ => '+243 990 000 000',
        };
      case 'tz':
        return switch (kind) {
          NotchPayChannelKind.tigo => '+255 650 000 000',
          NotchPayChannelKind.vodafone => '+255 740 000 000',
          NotchPayChannelKind.halopesa => '+255 620 000 000',
          _ => '+255 670 000 000',
        };
      case 'ke':
        return switch (kind) {
          NotchPayChannelKind.airtel => '+254 730 000 000',
          NotchPayChannelKind.equitel => '+254 760 000 000',
          NotchPayChannelKind.tkash => '+254 770 000 000',
          _ => '+254 700 000 000',
        };
      case 'gh':
        return switch (kind) {
          NotchPayChannelKind.vodafone => '+233 20 000 0000',
          NotchPayChannelKind.airtel => '+233 26 000 0000',
          _ => '+233 24 000 0000',
        };
      case 'td':
        return '+235 66 00 00 00';
      case 'cf':
        return '+236 70 00 00 00';
      case 'cg':
        return '+242 05 00 00 00';
      case 'cm':
      default:
        return switch (kind) {
          NotchPayChannelKind.orange => '+237 690 000 000',
          NotchPayChannelKind.yoomee => '+237 660 000 000',
          NotchPayChannelKind.eumm => '+237 680 000 000',
          _ => '+237 670 000 000',
        };
    }
  }
}
