import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart';

class InvoiceModel {
  final String id;
  final String orderId;
  final String customerName;
  final List<OrderItem> products;
  final double finalPrice;
  final DateTime date;

  InvoiceModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.products,
    required this.finalPrice,
    required this.date,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return InvoiceModel(
      id: docId,
      orderId: map['orderId'] ?? '',
      customerName: map['customerName'] ?? '',
      products: List<OrderItem>.from(
        (map['products'] as List? ?? []).map((x) => OrderItem.fromMap(x)),
      ),
      finalPrice: (map['finalPrice'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'products': products.map((x) => x.toMap()).toList(),
      'finalPrice': finalPrice,
      'date': date,
    };
  }
}
