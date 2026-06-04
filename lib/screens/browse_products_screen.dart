import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_environment.dart';
import '../models/catalog_browse_query.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_catalog_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

/// Product listing opened from the Menu (clothing / category finder).
class BrowseProductsScreen extends StatefulWidget {
  const BrowseProductsScreen({
    super.key,
    required this.environment,
    required this.query,
    this.initialSearch = '',
  });

  final AppEnvironment environment;
  final CatalogBrowseQuery query;
  final String initialSearch;

  @override
  State<BrowseProductsScreen> createState() => _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends State<BrowseProductsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final catalog = context.read<ProductCatalogProvider>();
      if (catalog.allProducts.isEmpty && !catalog.isLoading) {
        catalog.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filteredProducts(List<Product> all) {
    return widget.query.apply(all, searchQuery: _searchController.text);
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(environment: widget.environment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final catalog = context.watch<ProductCatalogProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final products = _filteredProducts(catalog.allProducts);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.query.screenTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: _openCart,
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search in ${widget.query.subCategory}',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey : Colors.grey.shade500,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${products.length} items',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(catalog, products, isDark)),
        ],
      ),
    );
  }

  Widget _buildBody(
    ProductCatalogProvider catalog,
    List<Product> products,
    bool isDark,
  ) {
    if (catalog.isLoading && catalog.allProducts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (catalog.error != null && catalog.allProducts.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load products',
        subtitle: catalog.error!,
        action: FilledButton(
          onPressed: catalog.loadProducts,
          child: const Text('Retry'),
        ),
      );
    }

    if (products.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No items found',
        subtitle:
            'Try another category or change your search for ${widget.query.screenTitle}.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          cartEnabled: widget.environment.cartEnabled,
          onAdd: () => context.read<CartProvider>().addProduct(product),
        );
      },
    );
  }
}
