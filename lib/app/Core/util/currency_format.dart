import 'package:fgtracker/l10n/l10n.dart';

/// Display helpers for amounts in the currency the backend sends
/// (Walkie orders, OTP charges). Unknown codes show as "AED 10.50".
class CurrencyFormat {
  CurrencyFormat._();

  /// Upper-cased ISO code, INR when missing
  static String code(String? currency) {
    final c = currency?.trim().toUpperCase() ?? '';
    return c.isEmpty ? 'INR' : c;
  }

  static bool isInr(String? currency) => code(currency) == 'INR';

  /// "₹", "$", "€", "£", otherwise the code plus a space
  static String symbol(String? currency) {
    final c = code(currency);
    switch (c) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$c ';
    }
  }

  /// "₹1,25,000" / "$125,000.50": symbol + grouped amount, 2 decimals only
  /// when there are paise / cents. Lakh grouping for INR, thousands otherwise.
  static String format(num amount, String? currency) {
    final c = code(currency);
    final negative = amount < 0;
    final abs = amount.abs();
    final hasFraction = abs != abs.roundToDouble();
    final fixed = abs.toStringAsFixed(hasFraction ? 2 : 0).split('.');
    final digits = fixed[0];
    String grouped;
    if (digits.length <= 3) {
      grouped = digits;
    } else if (c == 'INR') {
      final rest = digits.substring(0, digits.length - 3).replaceAllMapped(
          RegExp(r'(\d)(?=(\d\d)+$)'), (m) => '${m[1]},');
      grouped = '$rest,${digits.substring(digits.length - 3)}';
    } else {
      grouped = digits.replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    }
    final number = fixed.length > 1 ? '$grouped.${fixed[1]}' : grouped;
    return '${negative ? '-' : ''}${symbol(c)}$number';
  }

  /// Screen-reader text, e.g. "10 rupees 50 paise" or "10.50 US dollars"
  static String spoken(double amount, String? currency) {
    final c = code(currency);
    if (c == 'INR') {
      final paiseTotal = (amount * 100).round();
      final rupees = paiseTotal ~/ 100;
      final paise = paiseTotal % 100;
      return paise == 0
          ? appL10n.util_spokenRupees(rupees)
          : appL10n.util_spokenRupeesPaise(rupees, paise);
    }
    final value = amount.toStringAsFixed(2);
    switch (c) {
      case 'USD':
        return appL10n.util_spokenUsd(value);
      case 'EUR':
        return appL10n.util_spokenEur(value);
      case 'GBP':
        return appL10n.util_spokenGbp(value);
      default:
        return '$value $c';
    }
  }
}
