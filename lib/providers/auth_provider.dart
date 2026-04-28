// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:stockflow/models/transact_model.dart';
// import '../services/auth_service.dart' as auth_service;
// import '../services/product_service.dart' as product_service;
// import '../models/product_model.dart';
// import '../models/user_model.dart' as user_model;

// // ─── Services ──────────────────────────────────────────────────────

// final authServiceProvider =
//     Provider<auth_service.AuthService>((ref) => auth_service.AuthService());

// final productServiceProvider = Provider<product_service.ProductService>(
//     (ref) => product_service.ProductService());

// // ─── Auth ──────────────────────────────────────────────────────────

// final authStateProvider = StreamProvider<User?>((ref) {
//   return ref.watch(authServiceProvider).authStateChanges;
// });

// // ✅ FIXED: return correct variable (was 'stats')
// final userRoleProvider =
//     FutureProvider.family<user_model.UserRole, String>((ref, uid) async {
//   final role = await ref.watch(authServiceProvider).getUserRole(uid);
//   return role;
// });

// // ─── Products ──────────────────────────────────────────────────────

// final productsProvider = StreamProvider<List<ProductModel>>((ref) {
//   return ref.watch(productServiceProvider).watchAllProducts();
// });

// final lowStockProductsProvider = StreamProvider<List<ProductModel>>((ref) {
//   return ref.watch(productServiceProvider).watchLowStockProducts();
// });

// // ✅ FIXED: replaced firstOrNull (not standard in Dart)
// final productProvider =
//     Provider.family<AsyncValue<ProductModel?>, String>((ref, id) {
//   return ref.watch(productsProvider).whenData((products) {
//     try {
//       return products.firstWhere((p) => p.productId == id);
//     } catch (e) {
//       return null;
//     }
//   });
// });

// // ─── Transactions ──────────────────────────────────────────────────

// final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
//   return ref.watch(productServiceProvider).watchTransactions();
// });

// final productTransactionsProvider =
//     StreamProvider.family<List<TransactionModel>, String>((ref, productId) {
//   return ref.watch(productServiceProvider).watchProductTransactions(productId);
// });

// // ─── Dashboard stats ───────────────────────────────────────────────

// final dashboardStatsProvider =
//     FutureProvider<Map<String, dynamic>>((ref) async {
//   ref.watch(productsProvider); // keep if you want auto refresh
//   final stats = await ref.watch(productServiceProvider).getDashboardStats();
//   return stats;
// });

// // ─── Search ────────────────────────────────────────────────────────

// final searchQueryProvider = StateProvider<String>((ref) => '');

// final filteredProductsProvider =
//     Provider<AsyncValue<List<ProductModel>>>((ref) {
//   final query = ref.watch(searchQueryProvider).toLowerCase();
//   final products = ref.watch(productsProvider);

//   return products.whenData((list) {
//     if (query.isEmpty) return list;

//     return list.where((p) {
//       return p.name.toLowerCase().contains(query) ||
//           p.sku.toLowerCase().contains(query) ||
//           p.category.toLowerCase().contains(query);
//     }).toList();
//   });
// });
