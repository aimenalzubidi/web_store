import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerName;
  final List<OrderItem> products;
  final double totalPrice;
  final String status; // 'Pending', 'Accepted', 'Cancelled'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      customerName: map['customerName'] ?? 'Unknown',
      products: List<OrderItem>.from(
        (map['products'] as List? ?? []).map((x) => OrderItem.fromMap(x)),
      ),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'products': products.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({required this.productId, required this.name, required this.price, required this.quantity});

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
