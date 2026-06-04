import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.image,
    this.fit = BoxFit.contain,
  });

  final String image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final isLocal = image.startsWith('/') || image.startsWith('file:');

    if (isLocal && !kIsWeb) {
      final path =
          image.startsWith('file:') ? Uri.parse(image).toFilePath() : image;
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (_, __, ___) => _errorIcon(),
      );
    }

    return CachedNetworkImage(
      imageUrl: image,
      fit: fit,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) => _errorIcon(),
    );
  }

  Widget _errorIcon() {
    return Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey.shade400,
      size: 40,
    );
  }
}
