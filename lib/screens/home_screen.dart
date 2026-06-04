import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

import '../config/app_environment.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_catalog_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import 'admin_screen.dart';
import 'cart_screen.dart';
import 'menu_screen.dart';
import 'me_screen.dart';

import '../providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  int _selectedTabIndex = 1; // Default to 'MEN'
  final List<String> _tabs = ['WOMEN', 'MEN', 'KIDS', 'Z.HOME', 'LIFESTYLE'];

  /// Maps each tab to Fake Store API / local filter rules.
  static const List<_CategoryFilter> _tabFilters = [
    _CategoryFilter(
      tab: 'WOMEN',
      sectionTitle: "WOMEN'S COLLECTION",
      categories: ["women's clothing"],
    ),
    _CategoryFilter(
      tab: 'MEN',
      sectionTitle: "MEN'S COLLECTION",
      categories: ["men's clothing"],
    ),
    _CategoryFilter(
      tab: 'KIDS',
      sectionTitle: 'KIDS COLLECTION',
      categories: ["men's clothing", "women's clothing", 'kids'],
    ),
    _CategoryFilter(
      tab: 'Z.HOME',
      sectionTitle: 'Z.HOME',
      categories: ['electronics'],
    ),
    _CategoryFilter(
      tab: 'LIFESTYLE',
      sectionTitle: 'LIFESTYLE',
      categories: ['jewelery'],
    ),
  ];

  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductCatalogProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _CategoryFilter get _activeFilter => _tabFilters[_selectedTabIndex];

  List<Product> _filterProducts(List<Product> allProducts) {
    final filter = _activeFilter;
    final query = _searchController.text.trim().toLowerCase();

    Iterable<Product> results = allProducts.where(filter.matches);

    if (query.isNotEmpty) {
      results = results.where(
        (p) =>
            p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query),
      );
    }

    return results.toList();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTabIndex = index);
    _scrollToProducts();
  }

  void _scrollToProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent * 0.55,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(environment: widget.environment),
      ),
    );
  }

  void _openAdmin({Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AdminScreen(product: product)),
    );
  }

  void _addToCart(Product product) {
    context.read<CartProvider>().addProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final catalog = context.watch<ProductCatalogProvider>();
    final filteredProducts = _filterProducts(catalog.allProducts);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: _bottomNavIndex == 0 ? _buildAppBar(cartCount, isDark) : null,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildCategoryTabs(isDark)),
              SliverToBoxAdapter(child: _buildFreeDeliveryBanner(isDark, lang)),
              SliverToBoxAdapter(child: _buildMainBanner()),
              SliverToBoxAdapter(child: _buildBrandsSection()),
              SliverToBoxAdapter(child: _buildPromotionBanner()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    _activeFilter.sectionTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: _buildProductGrid(catalog, filteredProducts),
              ),
            ],
          ),
          MenuScreen(environment: widget.environment),
          MeScreen(environment: widget.environment),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(lang),
    );
  }

  PreferredSizeWidget _buildAppBar(int cartCount, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.notifications_none_outlined,
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: () {},
      ),
      title: Text(
        'ZANDO.',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Permanently visible Admin button to add new items
        IconButton(
          icon: Icon(
            Icons.add_box_outlined,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => _openAdmin(),
          tooltip: 'Add New Item',
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_bag_outlined,
                color: isDark ? Colors.white : Colors.black,
              ),
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
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedTabIndex;
          return GestureDetector(
            onTap: () => _onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFreeDeliveryBanner(bool isDark, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      alignment: Alignment.center,
      child: Text(
        lang.translate('free_delivery'),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: isDark ? Colors.white70 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      height: 400,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=1000&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'NEW ARRIVALS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'SHOP NOW',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsSection() {
    final brands = ['ZANDO.', 'TEN ELEVEN', 'GATONI', 'TAG SPACE', '361°'];
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  brands[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            width: 150,
            child: Image.network(
              'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?q=80&w=500&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ALL UNDER',
                  style: TextStyle(
                    color: Color(0xFF00ACC1),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  '\$9.99',
                  style: TextStyle(
                    color: Color(0xFF00ACC1),
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                  ),
                ),
                Text(
                  '*T&Cs APPLY',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    ProductCatalogProvider catalog,
    List<Product> filteredProducts,
  ) {
    if (catalog.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }
    if (catalog.error != null) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load products',
          subtitle: catalog.error!,
          action: FilledButton(
            onPressed: catalog.loadProducts,
            child: const Text('Retry'),
          ),
        ),
      );
    }
    if (filteredProducts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No items in ${_tabs[_selectedTabIndex]}',
          subtitle: 'Try another category or clear your search.',
        ),
      );
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          product: product,
          cartEnabled: widget.environment.cartEnabled,
          onAdd: () => _addToCart(product),
        );
      }, childCount: filteredProducts.length),
    );
  }

  Widget _buildBottomNav(LanguageProvider lang) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Z.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            label: lang.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _bottomNavIndex == 1
                  ? Icons.manage_search
                  : Icons.manage_search_outlined,
            ),
            label: lang.translate('menu'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: lang.translate('me'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter {
  const _CategoryFilter({
    required this.tab,
    required this.sectionTitle,
    required this.categories,
    this.titleKeywords = const [],
  });

  final String tab;
  final String sectionTitle;
  final List<String> categories;
  final List<String> titleKeywords;

  bool matches(Product product) {
    final category = product.category.toLowerCase();
    if (!categories.any((c) => category == c.toLowerCase())) {
      return false;
    }

    if (titleKeywords.isEmpty) return true;

    final haystack = '${product.title} ${product.description}'.toLowerCase();
    return titleKeywords.any(haystack.contains);
  }
}
