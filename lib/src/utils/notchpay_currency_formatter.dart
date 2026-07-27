/// Formats amounts for display in the checkout UI.
class NotchPayCurrencyFormatter {
  const NotchPayCurrencyFormatter._();

  static const _zeroDecimalCurrencies = {
    'XAF',
    'XOF',
    'BIF',
    'CLP',
    'DJF',
    'GNF',
    'JPY',
    'KMF'
  };

  /// Formats [amount] as `1 500 XAF`, grouping thousands with a plain ASCII
  /// space and hiding decimals for zero-decimal currencies like `XAF`.
  static String format(double amount, String currency) {
    final upperCurrency = currency.toUpperCase();
    final isZeroDecimal = _zeroDecimalCurrencies.contains(upperCurrency);
    final value = isZeroDecimal ? amount.round().toDouble() : amount;
    final text =
        isZeroDecimal ? value.toInt().toString() : value.toStringAsFixed(2);

    final wholeAndDecimal = text.split('.');
    final whole = wholeAndDecimal.first;
    final grouped = _groupThousands(whole);
    final decimal = wholeAndDecimal.length > 1 ? '.${wholeAndDecimal[1]}' : '';

    return '$grouped$decimal $upperCurrency';
  }

  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    final reversed = digits.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(reversed[i]);
    }
    return buffer.toString().split('').reversed.join();
  }
}
