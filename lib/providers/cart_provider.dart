import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  bool contains(Product product) => _items.containsKey(product.id);

  int quantityOf(Product product) => _items[product.id]?.quantity ?? 0;

  void addProduct(Product product) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void increaseQuantity(int productId) {
    final item = _items[productId];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
