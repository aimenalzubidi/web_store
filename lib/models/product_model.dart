class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final int stock;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.stock = 0,
    this.description = '',
  });

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      stock: map['stock'] ?? 0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'description': description,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    int? stock,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      description: description ?? this.description,
    );
  }
}
