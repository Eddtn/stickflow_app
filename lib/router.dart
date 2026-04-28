// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:stockflow/main_shell.dart';
// import 'package:stockflow/providers/auth_provider.dart';
// import 'package:stockflow/screens/auth/login_screen.dart';
// import 'package:stockflow/screens/dashboard/ashboard_screen.dart';
// import 'package:stockflow/screens/products/add_product.dart';
// import 'package:stockflow/screens/products/product_detail.dart';
// import 'package:stockflow/screens/products/products_screen.dart';
// import 'package:stockflow/screens/reports/reports_screen.dart';
// import 'package:stockflow/screens/setting_screen.dart';
// import 'package:stockflow/screens/splash_screen.dart';
// import 'package:stockflow/screens/transactions/add_transaction.dart';
// import 'package:stockflow/screens/transactions/transactions_screen.dart';
// import 'package:stockflow/screens/user_screen/user_mgt_screen.dart';

// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authStateProvider);

//   return GoRouter(
//     initialLocation: '/',
//     redirect: (context, state) {
//       final isLoggedIn = authState.valueOrNull != null;
//       final isAuthRoute =
//           state.matchedLocation == '/login' || state.matchedLocation == '/';

//       if (!isLoggedIn && !isAuthRoute) return '/login';
//       if (isLoggedIn && isAuthRoute) return '/dashboard';
//       return null;
//     },
//     routes: [
//       GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
//       GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
//       ShellRoute(
//         builder: (context, state, child) => MainShell(child: child),
//         routes: [
//           GoRoute(
//               path: '/dashboard', builder: (_, __) => const DashboardScreen()),
//           GoRoute(
//               path: '/products', builder: (_, __) => const ProductsScreen()),
//           GoRoute(
//               path: '/transactions',
//               builder: (_, __) => const TransactionsScreen()),
//           GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
//           GoRoute(
//               path: '/settings', builder: (_, __) => const SettingsScreen()),
//         ],
//       ),
//       GoRoute(
//           path: '/products/add', builder: (_, __) => const AddProductScreen()),
//       GoRoute(
//         path: '/products/:id',
//         builder: (_, state) =>
//             ProductDetailScreen(productId: state.pathParameters['id']!),
//       ),
//       GoRoute(
//         path: '/transactions/add',
//         builder: (_, state) => AddTransactionScreen(
//           preselectedProductId: state.uri.queryParameters['productId'],
//         ),
//       ),
//       GoRoute(path: '/users', builder: (_, __) => const UserManagementScreen()),
//     ],
//   );
// });
