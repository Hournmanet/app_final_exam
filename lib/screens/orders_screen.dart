import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/empty_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final orders = orderProvider.orders;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'My Orders',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orders.isEmpty
          ? const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No orders yet',
              subtitle: 'Your order history will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 8)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black),
                          ),
                          Text(
                            '${order.date.day}/${order.date.month}/${order.date.year}',
                            style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.grey,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  '${item.quantity}x ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                Expanded(
                                  child: Text(
                                    item.product.title,
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  formatPrice(item.lineTotal),
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatPrice(order.totalAmount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
