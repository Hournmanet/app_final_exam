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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List.from(items),
        totalAmount: total,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void cancelOrder(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
      notifyListeners();
    }
  }

  void updateOrderItems(String orderId, List<CartItem> newItems) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      double newTotal = 0;
      for (var item in newItems) {
        newTotal += item.lineTotal;
      }
      _orders[index] = _orders[index].copyWith(
        items: newItems,
        totalAmount: newTotal,
      );
      notifyListeners();
    }
  }
}
