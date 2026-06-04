import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  bool get hasOrders => _orders.isNotEmpty;

  Future<void> addOrder(List<CartItem> items, double total) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final newOrder = Order(
      id: orderId,
      items: List.from(items),
      totalAmount: total,
      date: DateTime.now(),
    );

    _orders.insert(0, newOrder);
    notifyListeners();

    // Sync with Supabase
    try {
      var user = _supabase.auth.currentUser;

      // If no user session, try to sign in anonymously as a fallback
      if (user == null) {
        debugPrint(
          'No active session found during sync. Attempting fallback anonymous sign-in...',
        );
        final response = await _supabase.auth.signInAnonymously();
        user = response.user;

        if (user == null) {
          debugPrint(
            'Supabase Sync Failed: Could not establish anonymous session. Check if Anonymous Auth is enabled in Supabase Dashboard.',
          );
          throw Exception(
            'You must be logged in or have guest access enabled to save order history.',
          );
        }
        debugPrint('Fallback anonymous sign-in successful: ${user.id}');
      }

      debugPrint('Supabase Sync Started: Order $orderId for User ${user.id}');

      // 1. Sync Products (Foreign Key requirement)
      final List<Map<String, dynamic>> productsData = items
          .map(
            (item) => {
              'id': item.product.id,
              'title': item.product.title,
              'price': item.product.price,
              'description': item.product.description,
              'category': item.product.category,
              'image_url': item.product.image,
            },
          )
          .toList();

      debugPrint(
        'Supabase Sync (1/3): Upserting ${productsData.length} products...',
      );
      debugPrint(
        'Product IDs to upsert: ${productsData.map((p) => p['id']).toList()}',
      );

      final productsResponse = await _supabase
          .from('products')
          .upsert(productsData)
          .select();
      debugPrint('Supabase Products Response: $productsResponse');

      // 2. Insert Order
      debugPrint(
        'Supabase Sync (2/3): Inserting order record with ID: $orderId',
      );
      final orderData = {
        'id': orderId,
        'user_id': user.id,
        'total_amount': total,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select();
      debugPrint('Supabase Order Response: $orderResponse');

      // 3. Insert Order Items
      final List<Map<String, dynamic>> itemsData = items
          .map(
            (item) => {
              'order_id': orderId,
              'product_id': item.product.id,
              'quantity': item.quantity,
              'unit_price': item.product.price,
            },
          )
          .toList();

      debugPrint(
        'Supabase Sync (3/3): Inserting ${itemsData.length} order items for Order ID: $orderId',
      );
      final itemsResponse = await _supabase
          .from('order_items')
          .insert(itemsData)
          .select();
      debugPrint('Supabase Order Items Response: $itemsResponse');

      debugPrint(
        'Supabase Sync Success: Order $orderId and its items are now in the database.',
      );
    } catch (e) {
      debugPrint('!!! Supabase Sync EXCEPTION [Order $orderId] !!!');
      debugPrint('Exception Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      if (e is PostgrestException) {
        debugPrint(
          'Postgrest Details -> Message: ${e.message}, Hint: ${e.hint}, Details: ${e.details}, Code: ${e.code}',
        );
      }
      rethrow;
    }
  }

  void cancelOrder(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
      notifyListeners();

      // Update in Supabase
      _supabase.from('orders').update({'status': 'cancelled'}).eq('id', id);
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

      // Update total in Supabase
      _supabase
          .from('orders')
          .update({'total_amount': newTotal})
          .eq('id', orderId);
    }
  }
}
