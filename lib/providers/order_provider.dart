import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen(_onAuthStateChange);
    Future.microtask(loadOrders);
  }

  final _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  final List<Order> _orders = [];
  bool _loading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get hasOrders => _orders.isNotEmpty;
  bool get isLoading => _loading;

  void _onAuthStateChange(AuthState data) {
    switch (data.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.tokenRefreshed:
        if (data.session != null) {
          loadOrders();
        }
        break;
      case AuthChangeEvent.signedOut:
        clearOrders();
        break;
      default:
        break;
    }
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  /// Loads order history for the signed-in user from Supabase.
  ///
  /// Uses separate queries (orders → order_items → products) because the DB
  /// may not expose a PostgREST FK between `order_items` and `products`.
  Future<void> loadOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      clearOrders();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      _orders.clear();

      final orderRows = await _fetchOrdersForUser(user.id);
      if (orderRows.isEmpty) {
        debugPrint('OrderProvider: No orders in database for ${user.email ?? user.id}');
        return;
      }

      final orderIds = orderRows
          .map((o) => o['id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      final itemsByOrderId = await _fetchOrderItemsByOrderIds(orderIds);
      final productIds = <int>{};
      for (final items in itemsByOrderId.values) {
        for (final item in items) {
          final id = item['product_id'];
          if (id is num) productIds.add(id.toInt());
        }
      }

      final productsById = await _fetchProductsByIds(productIds);

      for (final orderRow in orderRows) {
        final orderId = orderRow['id']?.toString() ?? '';
        final itemRows = itemsByOrderId[orderId] ?? [];
        final order = _buildOrder(
          orderRow,
          itemRows,
          productsById,
        );
        if (order != null) {
          _orders.add(order);
        }
      }

      debugPrint(
        'OrderProvider: Loaded ${_orders.length} orders for ${user.email ?? user.id}',
      );
    } catch (e) {
      debugPrint('OrderProvider: Failed to load orders: $e');
      if (e is PostgrestException) {
        debugPrint(
          'Postgrest -> ${e.message} (${e.code}) hint: ${e.hint}',
        );
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersForUser(String userId) async {
    final response = await _supabase
        .from('orders')
        .select('id, total_amount, status, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchOrderItemsByOrderIds(
    List<String> orderIds,
  ) async {
    if (orderIds.isEmpty) return {};

    final response = await _supabase
        .from('order_items')
        .select('order_id, product_id, quantity, unit_price')
        .inFilter('order_id', orderIds);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final orderId = row['order_id']?.toString() ?? '';
      if (orderId.isEmpty) continue;
      grouped.putIfAbsent(orderId, () => []).add(row);
    }
    return grouped;
  }

  Future<Map<int, Product>> _fetchProductsByIds(Set<int> productIds) async {
    if (productIds.isEmpty) return {};

    final response = await _supabase
        .from('products')
        .select('id, title, price, description, category, image_url')
        .inFilter('id', productIds.toList());

    final map = <int, Product>{};
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final product = _productFromSupabase(row);
      map[product.id] = product;
    }
    return map;
  }

  Order? _buildOrder(
    Map<String, dynamic> orderRow,
    List<Map<String, dynamic>> itemRows,
    Map<int, Product> productsById,
  ) {
    if (itemRows.isEmpty) return null;

    final items = <CartItem>[];
    for (final itemRow in itemRows) {
      final productId = (itemRow['product_id'] as num?)?.toInt();
      final quantity = (itemRow['quantity'] as num?)?.toInt() ?? 1;
      final unitPrice = (itemRow['unit_price'] as num?)?.toDouble() ?? 0;

      if (productId == null) continue;

      final product = productsById[productId] ??
          Product(
            id: productId,
            title: 'Product #$productId',
            price: unitPrice,
            description: '',
            category: '',
            image: '',
          );

      items.add(CartItem(product: product, quantity: quantity));
    }

    if (items.isEmpty) return null;

    final id = orderRow['id']?.toString() ?? '';
    if (id.isEmpty) return null;

    final status = orderRow['status'] == 'cancelled'
        ? OrderStatus.cancelled
        : OrderStatus.active;

    final createdAt = orderRow['created_at'];
    final date = createdAt is String
        ? DateTime.tryParse(createdAt) ?? DateTime.now()
        : DateTime.now();

    final total =
        (orderRow['total_amount'] as num?)?.toDouble() ??
        items.fold<double>(0, (sum, i) => sum + i.lineTotal);

    return Order(
      id: id,
      items: items,
      totalAmount: total,
      date: date,
      status: status,
    );
  }

  Product _productFromSupabase(Map<String, dynamic> row) {
    return Product(
      id: (row['id'] as num).toInt(),
      title: row['title'] as String? ?? 'Product',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      description: row['description'] as String? ?? '',
      category: row['category'] as String? ?? '',
      image: (row['image_url'] ?? row['image'] ?? '') as String,
    );
  }

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

    try {
      var user = _supabase.auth.currentUser;

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

      await _supabase.from('products').upsert(productsData).select();

      final orderData = {
        'id': orderId,
        'user_id': user.id,
        'total_amount': total,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Supabase Sync (2/3): Inserting order record with ID: $orderId');

      await _supabase.from('orders').insert(orderData).select();

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
        'Supabase Sync (3/3): Inserting ${itemsData.length} order items...',
      );

      await _supabase.from('order_items').insert(itemsData).select();

      debugPrint(
        'Supabase Sync Success: Order $orderId saved for user ${user.id}',
      );
    } catch (e) {
      debugPrint('!!! Supabase Sync EXCEPTION [Order $orderId] !!!');
      debugPrint('Error Message: $e');
      if (e is PostgrestException) {
        debugPrint(
          'Postgrest Details -> Message: ${e.message}, Code: ${e.code}',
        );
      }
      rethrow;
    }
  }

  Future<void> cancelOrder(String id) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
    notifyListeners();

    try {
      await _supabase.from('orders').update({'status': 'cancelled'}).eq('id', id);
    } catch (e) {
      debugPrint('OrderProvider: Failed to cancel order in Supabase: $e');
    }
  }

  Future<void> updateOrderItems(String orderId, List<CartItem> newItems) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    double newTotal = 0;
    for (final item in newItems) {
      newTotal += item.lineTotal;
    }

    _orders[index] = _orders[index].copyWith(
      items: newItems,
      totalAmount: newTotal,
    );
    notifyListeners();

    try {
      await _supabase
          .from('orders')
          .update({'total_amount': newTotal})
          .eq('id', orderId);
    } catch (e) {
      debugPrint('OrderProvider: Failed to update order in Supabase: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
