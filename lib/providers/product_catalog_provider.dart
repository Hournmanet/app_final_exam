import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductCatalogProvider extends ChangeNotifier {
  ProductCatalogProvider({ProductApiService? api})
      : _api = api ?? ProductApiService();

  final ProductApiService _api;

  List<Product> _apiProducts = [];
  final List<Product> _localProducts = [];
  bool _loading = false;
  String? _error;
  int _nextLocalId = -1;

  bool get isLoading => _loading;
  String? get error => _error;

  List<Product> get allProducts => [..._localProducts, ..._apiProducts];

  Future<void> loadProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _apiProducts = await _api.fetchProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void addProduct({
    required String title,
    required double price,
    required String description,
    required String category,
    required String imagePath,
  }) {
    final product = Product(
      id: _nextLocalId--,
      title: title.trim(),
      price: price,
      description: description.trim(),
      category: normalizeCategory(category),
      image: imagePath,
    );
    _localProducts.insert(0, product);
    notifyListeners();
  }

  void updateProduct({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    String? imagePath,
  }) {
    final index = _localProducts.indexWhere((p) => p.id == id);
    if (index == -1) {
      final apiIndex = _apiProducts.indexWhere((p) => p.id == id);
      if (apiIndex == -1) return;
      final existing = _apiProducts[apiIndex];
      _localProducts.insert(
        0,
        Product(
          id: _nextLocalId--,
          title: title.trim(),
          price: price,
          description: description.trim(),
          category: normalizeCategory(category),
          image: imagePath ?? existing.image,
          rating: existing.rating,
        ),
      );
      notifyListeners();
      return;
    }

    final existing = _localProducts[index];
    _localProducts[index] = Product(
      id: existing.id,
      title: title.trim(),
      price: price,
      description: description.trim(),
      category: normalizeCategory(category),
      image: imagePath ?? existing.image,
      rating: existing.rating,
    );
    notifyListeners();
  }

  /// Maps admin form categories to values used by home-screen filters.
  static String normalizeCategory(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.contains('women') || value == 'woman') {
      return "women's clothing";
    }
    if (value.contains('kid')) return 'kids';
    if (value.contains('jewel') || value.contains('lifestyle')) {
      return 'jewelery';
    }
    if (value.contains('electronic') ||
        value.contains('home') ||
        value.contains('z.home')) {
      return 'electronics';
    }
    if (value.contains('men')) return "men's clothing";
    return raw.trim();
  }
}
