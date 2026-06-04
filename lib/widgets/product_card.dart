import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/product.dart';
import '../utils/currency_formatter.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    required this.cartEnabled,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  final Product product;
  final VoidCallback onAdd;
  final bool cartEnabled;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _showAddedMessage = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleAdd() {
    widget.onAdd();
    _resetTimer?.cancel();
    setState(() => _showAddedMessage = true);
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showAddedMessage = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.cartEnabled && !widget.isAdmin ? _handleAdd : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: ProductImage(image: widget.product.image),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        widget.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          formatPrice(widget.product.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.product.rating != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber.shade600,
                          ),
                          Text(
                            widget.product.rating!.rate.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                    if (widget.cartEnabled && !widget.isAdmin) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: _showAddedMessage
                            ? const _AddedToBagMessage()
                            : FilledButton.icon(
                                onPressed: _handleAdd,
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Add to bag',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                      ),
                    ],
                    if (widget.isAdmin) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onEdit,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: widget.onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddedToBagMessage extends StatelessWidget {
  const _AddedToBagMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, size: 18, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Added to bag',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
