import '../models/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime date;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
  });
}
