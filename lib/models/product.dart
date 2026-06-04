class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final ProductRating? rating;

  bool get hasLocalImage =>
      image.startsWith('/') || image.startsWith('file:');

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: json['rating'] != null
          ? ProductRating.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProductRating {
  const ProductRating({required this.rate, required this.count});

  final double rate;
  final int count;

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}
