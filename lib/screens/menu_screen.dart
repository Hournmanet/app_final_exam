import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_environment.dart';
import '../models/catalog_browse_query.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import 'browse_products_screen.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedTabIndex = 0;
  final _searchController = TextEditingController();
  final List<String> _tabs = ['WOMEN', 'MEN', 'KIDS', 'Z.HOME', 'LIFESTYLE'];

  final Map<String, List<String>> _menuItems = {
    'WOMEN': [
      'New In',
      'Clothing',
      'Accessories',
      'Shoes',
      'Shop by collection',
      'SALE',
    ],
    'MEN': [
      'New In',
      'Clothing',
      'Accessories',
      'Shoes',
      'Shop by collection',
      'SALE',
    ],
    'KIDS': ['Boys', 'Girls'],
    'Z.HOME': [
      'New In',
      'Bedroom Essentials',
      'Bath Essentials',
      'Living Essentials',
      'Kitchen Essentials',
    ],
    'LIFESTYLE': [
      'New In',
      'Accessories',
      'Blind Boxes',
      'Home Goods',
      'Plushies',
      'Stationery',
      'Toys',
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _selectedDepartment => _tabs[_selectedTabIndex];

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(environment: widget.environment),
      ),
    );
  }

  void _openBrowse(String subCategory) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseProductsScreen(
          environment: widget.environment,
          query: CatalogBrowseQuery(
            departmentTab: _selectedDepartment,
            subCategory: subCategory,
          ),
        ),
      ),
    );
  }

  void _openSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseProductsScreen(
          environment: widget.environment,
          query: CatalogBrowseQuery(
            departmentTab: _selectedDepartment,
            subCategory: 'Shop by collection',
          ),
          initialSearch: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'ZANDO.',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            color: isDark ? Colors.white : Colors.black,
            size: 28,
          ),
          onPressed: () {},
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: isDark ? Colors.white : Colors.black,
                  size: 28,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _openSearch(),
                    decoration: InputDecoration(
                      hintText: 'What are you searching for?',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey : Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              _buildCategoryTabs(isDark),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFreeDeliveryBanner(isDark),
          Expanded(
            child: ListView.separated(
              itemCount: _menuItems[_selectedDepartment]!.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.white10 : Colors.grey.shade100,
              ),
              itemBuilder: (context, index) {
                final item = _menuItems[_selectedDepartment]![index];
                final isSale = item == 'SALE';
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSale
                          ? Colors.red
                          : (isDark ? Colors.white : Colors.black),
                      fontSize: 16,
                      fontWeight: isSale ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isSale
                        ? Colors.red
                        : (isDark ? Colors.white : Colors.black),
                  ),
                  onTap: () => _openBrowse(item),
                );
              },
            ),
          ),
        ],
      ),
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
            onTap: () => setState(() => _selectedTabIndex = index),
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFreeDeliveryBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
      alignment: Alignment.center,
      child: Text(
        'Free delivery with up to 40+ USD Spent',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white70 : Colors.black,
        ),
      ),
    );
  }
}
