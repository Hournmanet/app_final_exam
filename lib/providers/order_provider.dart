import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  bool get hasOrders => _orders.isNotEmpty;

  void addOrder(List<CartItem> items, double total) {
    _orders.insert(
      0,
      Order(
        id: DateTime.now().toString(),
        items: List.from(items),
        totalAmount: total,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
