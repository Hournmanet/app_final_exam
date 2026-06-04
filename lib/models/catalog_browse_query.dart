import 'product.dart';

/// Describes a Menu → department → subcategory selection for product browsing.
class CatalogBrowseQuery {
  const CatalogBrowseQuery({
    required this.departmentTab,
    required this.subCategory,
  });

  final String departmentTab;
  final String subCategory;

  String get screenTitle {
    if (subCategory == 'SALE') return 'SALE · $departmentTab';
    return '$subCategory · $departmentTab';
  }

  List<String> get _baseCategories {
    switch (departmentTab) {
      case 'WOMEN':
        return ["women's clothing"];
      case 'MEN':
        return ["men's clothing"];
      case 'KIDS':
        return ["men's clothing", "women's clothing", 'kids'];
      case 'Z.HOME':
        return ['electronics'];
      case 'LIFESTYLE':
        return ['jewelery'];
      default:
        return [];
    }
  }

  List<String> get _categories {
    final base = _baseCategories;
    if (subCategory == 'Accessories' &&
        (departmentTab == 'WOMEN' || departmentTab == 'MEN' || departmentTab == 'LIFESTYLE')) {
      return [...base, 'jewelery'];
    }
    return base;
  }

  List<String> get _titleKeywords {
    switch (subCategory) {
      case 'New In':
      case 'Clothing':
      case 'Shop by collection':
        return const [];
      case 'Accessories':
        return const [
          'bag',
          'watch',
          'jewel',
          'ring',
          'wallet',
          'belt',
          'hat',
          'scarf',
          'sunglass',
          'necklace',
          'bracelet',
          'earring',
        ];
      case 'Shoes':
        return const ['shoe', 'sneaker', 'boot', 'sandal', 'heel', 'slipper'];
      case 'Boys':
        return const ['boy', 'boys', 'kid'];
      case 'Girls':
        return const ['girl', 'girls', 'kid'];
      case 'Bedroom Essentials':
        return const ['bed', 'pillow', 'blanket', 'mattress', 'sheet'];
      case 'Bath Essentials':
        return const ['bath', 'towel', 'soap', 'shower'];
      case 'Living Essentials':
        return const ['chair', 'sofa', 'lamp', 'table', 'living'];
      case 'Kitchen Essentials':
        return const ['kitchen', 'cook', 'pan', 'plate', 'mug'];
      case 'Blind Boxes':
        return const ['box', 'blind', 'mystery'];
      case 'Home Goods':
        return const ['home', 'decor', 'candle', 'vase'];
      case 'Plushies':
        return const ['plush', 'stuffed', 'toy'];
      case 'Stationery':
        return const ['pen', 'notebook', 'stationery', 'paper'];
      case 'Toys':
        return const ['toy', 'game', 'puzzle'];
      case 'SALE':
        return const [];
      default:
        return const [];
    }
  }

  bool matches(Product product) {
    final category = product.category.toLowerCase();
    if (!_categories.any((c) => category == c.toLowerCase())) {
      return false;
    }

    if (subCategory == 'SALE') {
      return product.price <= 50;
    }

    if (_titleKeywords.isEmpty) return true;

    final haystack = '${product.title} ${product.description}'.toLowerCase();
    return _titleKeywords.any(haystack.contains);
  }

  /// Prefer newest items for "New In".
  int compareForDisplay(Product a, Product b) {
    if (subCategory == 'New In') {
      return b.id.compareTo(a.id);
    }
    return a.title.compareTo(b.title);
  }

  List<Product> apply(List<Product> all, {String searchQuery = ''}) {
    final query = searchQuery.trim().toLowerCase();
    var results = all.where(matches).toList();

    if (results.isEmpty && subCategory != 'SALE') {
      results = all.where((p) {
        final category = p.category.toLowerCase();
        return _categories.any((c) => category == c.toLowerCase());
      }).toList();
    }

    if (query.isNotEmpty) {
      results = results
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query),
          )
          .toList();
    }

    results.sort(compareForDisplay);
    return results;
  }
}
