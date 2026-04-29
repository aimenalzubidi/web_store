import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/invoice_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== AUTH ==========
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Optional: Check if user is admin in Firestore
      final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        return cred.user;
      } else {
        await _auth.signOut();
        throw Exception('You are not authorized to login.');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ========== PRODUCTS ==========
  Future<List<Product>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Product> addProduct(Product product) async {
    final docRef = _firestore.collection('products').doc();
    Product newProduct = product.copyWith(id: docRef.id);
    await docRef.set(newProduct.toMap());
    return newProduct;
  }

  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // ========== ORDERS ==========
  Stream<List<OrderModel>> getOrdersStream() {
    return _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
  }

  // ========== INVOICES ==========
  Future<List<InvoiceModel>> getInvoices() async {
    final snapshot = await _firestore.collection('invoices').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<InvoiceModel> addInvoice(InvoiceModel invoice) async {
    final docRef = _firestore.collection('invoices').doc();
    InvoiceModel newInvoice = InvoiceModel(
      id: docRef.id,
      orderId: invoice.orderId,
      customerName: invoice.customerName,
      products: invoice.products,
      finalPrice: invoice.finalPrice,
      date: invoice.date,
    );
    await docRef.set(newInvoice.toMap());
    return newInvoice;
  }
}
