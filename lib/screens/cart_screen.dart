import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_environment.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/checkout_success_dialog.dart';
import '../widgets/product_image.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add products from the home screen.',
              action: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue shopping'),
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
                      );
                    },
                  ),
                ),
                _CheckoutBar(
                  total: cart.totalPrice,
                  onCheckout: () => _checkout(context, cart),
                ),
              ],
            ),
    );
  }

  Future<void> _checkout(BuildContext context, CartProvider cart) async {
    // Save order before clearing cart
    final orderProvider = context.read<OrderProvider>();
    orderProvider.addOrder(cart.items, cart.totalPrice);

    await showCheckoutSuccessDialog(context);
    if (!context.mounted) return;
    cart.clear();
    Navigator.of(context).popUntil((route) => route.isFirst);
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
  });

  final String title;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                color: AppTheme.surface,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(unitPrice),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: onDecrease),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _QtyButton(icon: Icons.add, onTap: onIncrease),
                      const Spacer(),
                      Text(
                        formatPrice(lineTotal),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.primary,
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
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});

  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  Text(
                    formatPrice(total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.payment),
              label: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
