import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class LocalDbService {
  static const String _productsKey = 'local_products';

  Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encoded = products.map((p) => json.encode(p.toMap()..putIfAbsent('id', () => p.id))).toList();
    await prefs.setStringList(_productsKey, encoded);
  }

  Future<List<Product>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encoded = prefs.getStringList(_productsKey);
    if (encoded == null) return [];
    return encoded.map((str) {
      final map = json.decode(str) as Map<String, dynamic>;
      return Product.fromMap(map, map['id'] ?? '');
    }).toList();
  }
}
