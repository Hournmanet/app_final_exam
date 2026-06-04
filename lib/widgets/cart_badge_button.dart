import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({
    super.key,
    required this.itemCount,
    required this.onPressed,
  });

  final int itemCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
          ),
        ),
        if (itemCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
