import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatUSD(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    final formatter = NumberFormat.compactCurrency(symbol: '\$');
    return formatter.format(amount);
  }
}
