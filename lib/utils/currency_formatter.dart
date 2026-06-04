import 'package:intl/intl.dart';

final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');

String formatPrice(double amount) => currencyFormat.format(amount);
