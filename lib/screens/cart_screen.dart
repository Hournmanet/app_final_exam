import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_environment.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/product_image.dart';
import '../widgets/empty_state.dart';
import 'checkout_flow_screen.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('My Bag', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            ),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('History', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your bag is empty',
              subtitle: 'Add products from the home screen.',
              action: Column(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continue shopping'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()),
                    ),
                    child: const Text('View Order History'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _CartItemTile(
                        title: item.product.title,
                        imageUrl: item.product.image,
                        unitPrice: item.product.price,
                        quantity: item.quantity,
                        lineTotal: item.lineTotal,
                        onIncrease: () =>
                            cart.increaseQuantity(item.product.id),
                        onDecrease: () =>
                            cart.decreaseQuantity(item.product.id),
                        onRemove: () => cart.removeProduct(item.product.id),
                        isDark: isDark,
                      );
                    },
                  ),
                ),
                _CheckoutBar(
                  total: cart.totalPrice,
                  onCheckout: () => _startCheckout(context),
                  isDark: isDark,
                ),
              ],
            ),
    );
  }

  void _startCheckout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutFlowScreen(environment: environment),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.title,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.isDark,
  });

  final String title;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72,
                height: 72,
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppTheme.surface,
                child: ProductImage(image: imageUrl, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(unitPrice),
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: onDecrease, isDark: isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      _QtyButton(icon: Icons.add, onTap: onIncrease, isDark: isDark),
                      const Spacer(),
                      Text(
                        formatPrice(lineTotal),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isDark ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: onRemove,
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap, required this.isDark});

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white10 : AppTheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: isDark ? Colors.white : AppTheme.primary),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout, required this.isDark});

  final double total;
  final VoidCallback onCheckout;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: isDark ? const Border(top: BorderSide(color: Colors.white10)) : null,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 13),
                  ),
                  Text(
                    formatPrice(total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.payment),
              label: const Text('Checkout'),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
