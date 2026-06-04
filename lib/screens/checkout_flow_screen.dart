import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_environment.dart';
import '../config/app_theme.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/checkout_success_dialog.dart';
import '../widgets/product_image.dart';

class CheckoutFlowScreen extends StatefulWidget {
  const CheckoutFlowScreen({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  State<CheckoutFlowScreen> createState() => _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends State<CheckoutFlowScreen> {
  static const _stepLabels = ['Delivery', 'Payment', 'Verify'];

  int _step = 0;
  bool _isPlacingOrder = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  String _paymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController = TextEditingController(text: user.fullName.trim());
    _phoneController = TextEditingController(text: user.phoneNumber);
    _emailController = TextEditingController(text: user.email);
    _addressController = TextEditingController(text: user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _continue() {
    if (_step == 0 && !_validateDelivery()) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    _placeOrder();
  }

  bool _validateDelivery() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in name, phone, and delivery address.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    try {
      await context.read<OrderProvider>().addOrder(cart.items, cart.totalPrice);
      if (!mounted) return;

      await showCheckoutSuccessDialog(context);
      if (!mounted) return;

      cart.clear();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _placeOrder,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String get _paymentLabel {
    switch (_paymentMethod) {
      case 'card':
        return 'Credit / Debit Card';
      case 'aba':
        return 'ABA Pay';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return _paymentMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final total = cart.totalPrice;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: _isPlacingOrder ? null : _goBack,
        ),
        title: Text(
          'Checkout (${_step + 1}/3)',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step, labels: _stepLabels, isDark: isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _step == 0
                    ? _DeliveryStep(
                        key: const ValueKey(0),
                        nameController: _nameController,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        addressController: _addressController,
                        isDark: isDark,
                      )
                    : _step == 1
                    ? _PaymentStep(
                        key: const ValueKey(1),
                        paymentMethod: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v),
                        isDark: isDark,
                      )
                    : _VerifyStep(
                        key: const ValueKey(2),
                        items: items,
                        total: total,
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        email: _emailController.text.trim(),
                        address: _addressController.text.trim(),
                        paymentLabel: _paymentLabel,
                        isDark: isDark,
                      ),
              ),
            ),
          ),
          _BottomBar(
            step: _step,
            total: total,
            isPlacingOrder: _isPlacingOrder,
            isDark: isDark,
            onPressed: _isPlacingOrder ? null : _continue,
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.labels,
    required this.isDark,
  });

  final int currentStep;
  final List<String> labels;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;
            final done = lineIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: done
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white24 : Colors.grey.shade300),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final active = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;

          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white12 : Colors.grey.shade200),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: active
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isCurrent
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white54 : Colors.grey),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.isDark,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Step 1 — Delivery details', isDark: isDark),
        const SizedBox(height: 16),
        _CheckoutField(label: 'Full name', controller: nameController, isDark: isDark),
        const SizedBox(height: 16),
        _CheckoutField(
          label: 'Mobile number',
          controller: phoneController,
          isDark: isDark,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _CheckoutField(
          label: 'Email',
          controller: emailController,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _CheckoutField(
          label: 'Delivery address',
          controller: addressController,
          isDark: isDark,
          maxLines: 3,
        ),
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    super.key,
    required this.paymentMethod,
    required this.onChanged,
    required this.isDark,
  });

  final String paymentMethod;
  final ValueChanged<String> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Step 2 — Payment method', isDark: isDark),
        const SizedBox(height: 16),
        _PaymentTile(
          title: 'Credit / Debit Card',
          subtitle: 'Visa, Mastercard',
          icon: Icons.credit_card,
          value: 'card',
          groupValue: paymentMethod,
          onChanged: onChanged,
          isDark: isDark,
        ),
        _PaymentTile(
          title: 'ABA Pay',
          subtitle: 'Pay with ABA mobile',
          icon: Icons.account_balance_wallet_outlined,
          value: 'aba',
          groupValue: paymentMethod,
          onChanged: onChanged,
          isDark: isDark,
        ),
        _PaymentTile(
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive',
          icon: Icons.payments_outlined,
          value: 'cod',
          groupValue: paymentMethod,
          onChanged: onChanged,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({
    super.key,
    required this.items,
    required this.total,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.paymentLabel,
    required this.isDark,
  });

  final List<CartItem> items;
  final double total;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String paymentLabel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Step 3 — Verify your order', isDark: isDark),
        const SizedBox(height: 8),
        Text(
          'Review everything below before you confirm.',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        _VerifyCard(
          title: 'Delivery',
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VerifyLine('Name', name, isDark),
              _VerifyLine('Phone', phone, isDark),
              if (email.isNotEmpty) _VerifyLine('Email', email, isDark),
              _VerifyLine('Address', address, isDark),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _VerifyCard(
          title: 'Payment',
          isDark: isDark,
          child: _VerifyLine('Method', paymentLabel, isDark),
        ),
        const SizedBox(height: 12),
        _VerifyCard(
          title: 'Items (${items.length})',
          isDark: isDark,
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: ProductImage(
                              image: item.product.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                'Qty ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatPrice(item.lineTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order total',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              formatPrice(total),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.label,
    required this.controller,
    required this.isDark,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool isDark;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white12 : Colors.grey.shade200),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.white : Colors.black),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
                  activeColor: isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyCard extends StatelessWidget {
  const _VerifyCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  final String title;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _VerifyLine extends StatelessWidget {
  const _VerifyLine(this.label, this.value, this.isDark);

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.total,
    required this.isPlacingOrder,
    required this.isDark,
    required this.onPressed,
  });

  final int step;
  final double total;
  final bool isPlacingOrder;
  final bool isDark;
  final VoidCallback? onPressed;

  String get _buttonLabel {
    if (isPlacingOrder) return 'Placing order...';
    if (step == 2) return 'Confirm order';
    return 'Continue';
  }

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
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    formatPrice(total),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: isDark ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: isPlacingOrder
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
