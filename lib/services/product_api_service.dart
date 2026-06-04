import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiService {
  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get(Uri.parse('$_baseUrl/products'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
