/// Card networks recognized by [NotchPayCardUtils.detectBrand].
enum NotchPayCardBrand {
  /// Visa.
  visa,

  /// Mastercard.
  mastercard,

  /// American Express.
  americanExpress,

  /// Discover.
  discover,

  /// A brand that could not be recognized from the number.
  unknown;

  /// A human friendly display name for this brand.
  String get label => switch (this) {
        NotchPayCardBrand.visa => 'Visa',
        NotchPayCardBrand.mastercard => 'Mastercard',
        NotchPayCardBrand.americanExpress => 'American Express',
        NotchPayCardBrand.discover => 'Discover',
        NotchPayCardBrand.unknown => 'Card',
      };
}

/// Client-side helpers to validate a bank card before submitting it,
/// improving the user experience by catching typos instantly instead of
/// waiting for a server round trip.
///
/// This package never stores or transmits raw card numbers itself; card
/// collection is always delegated to NotchPay's own secure card element /
/// redirect flow. These helpers only drive the UI (brand icon, input mask,
/// inline validation).
class NotchPayCardUtils {
  const NotchPayCardUtils._();

  /// Detects the card brand from its (partial or full) [number].
  static NotchPayCardBrand detectBrand(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return NotchPayCardBrand.unknown;
    if (RegExp(r'^4').hasMatch(digits)) return NotchPayCardBrand.visa;
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) {
      return NotchPayCardBrand.mastercard;
    }
    if (RegExp(r'^3[47]').hasMatch(digits)) {
      return NotchPayCardBrand.americanExpress;
    }
    if (RegExp(r'^6(?:011|5)').hasMatch(digits)) {
      return NotchPayCardBrand.discover;
    }
    return NotchPayCardBrand.unknown;
  }

  /// Validates [number] using the Luhn checksum algorithm.
  static bool isValidLuhn(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12) return false;

    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = int.parse(digits[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Whether [expiry] in `MM/YY` format is a valid, non-expired date.
  static bool isValidExpiry(String expiry) {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(expiry.trim());
    if (match == null) return false;
    final month = int.parse(match.group(1)!);
    final year = int.parse('20${match.group(2)!}');
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1);
    return expiryDate.isAfter(now);
  }

  /// Splits [number] into groups of 4 digits for display, e.g.
  /// `4242424242424242` -> `4242 4242 4242 4242`.
  static String formatForDisplay(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
