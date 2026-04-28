// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:stockflow/models/transact_model.dart';
// import '../models/product_model.dart';

// class ProductService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // ─── Products ─────────────────────────────────────────────────

//   Stream<List<ProductModel>> watchAllProducts() {
//     return _db
//         .collection('products')
//         .orderBy('name')
//         .snapshots()
//         .map((snap) => snap.docs.map(ProductModel.fromFirestore).toList());
//   }

//   Stream<List<ProductModel>> watchLowStockProducts() {
//     // Firestore can't compare two fields directly, so we fetch and filter client-side
//     return watchAllProducts().map(
//       (products) => products.where((p) => p.isLowStock).toList(),
//     );
//   }

//   Future<ProductModel?> getProduct(String productId) async {
//     final doc = await _db.collection('products').doc(productId).get();
//     if (!doc.exists) return null;
//     return ProductModel.fromFirestore(doc);
//   }

//   Future<String> addProduct(ProductModel product) async {
//     final ref = await _db.collection('products').add(product.toFirestore());
//     return ref.id;
//   }

//   Future<void> updateProduct(ProductModel product) async {
//     await _db
//         .collection('products')
//         .doc(product.productId)
//         .update(product.toFirestore());
//   }

//   Future<void> deleteProduct(String productId) async {
//     await _db.collection('products').doc(productId).delete();
//   }

//   // ─── Transactions (stock in / out) ────────────────────────────

//   Future<void> recordTransaction({
//     required String productId,
//     required String productName,
//     required TransactionType type,
//     required int quantity,
//     required String reason,
//     required String performedBy,
//     required String performedByName,
//     String? note,
//   }) async {
//     final productRef = _db.collection('products').doc(productId);
//     final txRef = _db.collection('transactions').doc();

//     await _db.runTransaction((txn) async {
//       final productSnap = await txn.get(productRef);
//       final currentQty = productSnap.data()?['quantity'] as int? ?? 0;

//       final delta = type == TransactionType.stockIn ? quantity : -quantity;
//       final newQty = currentQty + delta;

//       if (newQty < 0) {
//         throw Exception(
//             'Insufficient stock. Current: $currentQty, Requested: $quantity');
//       }

//       // Update product quantity
//       txn.update(productRef, {
//         'quantity': newQty,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       // Write transaction record
//       txn.set(txRef, {
//         'productId': productId,
//         'productName': productName,
//         'type': type == TransactionType.stockIn ? 'in' : 'out',
//         'quantity': quantity,
//         'reason': reason,
//         'performedBy': performedBy,
//         'performedByName': performedByName,
//         'timestamp': FieldValue.serverTimestamp(),
//         'note': note,
//         'prevQty': currentQty,
//         'newQty': newQty,
//       });
//     });
//   }

//   Stream<List<TransactionModel>> watchTransactions({int limit = 50}) {
//     return _db
//         .collection('transactions')
//         .orderBy('timestamp', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());
//   }

//   Stream<List<TransactionModel>> watchProductTransactions(String productId) {
//     return _db
//         .collection('transactions')
//         .where('productId', isEqualTo: productId)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs.map(TransactionModel.fromFirestore).toList());
//   }

//   // ─── Analytics ────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getDashboardStats() async {
//     final products = await _db.collection('products').get();
//     final productList = products.docs.map(ProductModel.fromFirestore).toList();

//     final totalProducts = productList.length;
//     final lowStockCount = productList.where((p) => p.isLowStock).length;
//     final outOfStockCount = productList.where((p) => p.isOutOfStock).length;
//     final totalValue = productList.fold<double>(
//         0, (sum, p) => sum + (p.quantity * p.unitPrice));

//     return {
//       'totalProducts': totalProducts,
//       'lowStockCount': lowStockCount,
//       'outOfStockCount': outOfStockCount,
//       'totalInventoryValue': totalValue,
//     };
//   }
// }
