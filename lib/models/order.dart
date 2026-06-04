import '../models/cart_item.dart';

enum OrderStatus { active, cancelled }

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime date;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = OrderStatus.active,
  });

  Order copyWith({
    List<CartItem>? items,
    double? totalAmount,
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date,
      status: status ?? this.status,
    );
  }
}
