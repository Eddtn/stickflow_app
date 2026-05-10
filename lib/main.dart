// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'core/theme.dart';
// import 'router.dart';
// import 'services/notification_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await NotificationService.init();
//   runApp(const ProviderScope(child: StockFlowApp()));
// }

// class StockFlowApp extends ConsumerWidget {
//   const StockFlowApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(routerProvider);
//     return MaterialApp.router(
//       title: 'StockFlow',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light,
//       routerConfig: router,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:stockflow/features/auth/login_screen.dart';
import 'package:stockflow/features/bottom_navigation_screen/bottom_nav_screen.dart';
import 'package:stockflow/features/dashboard/ashboard_screen.dart';
import 'package:stockflow/features/posscreen/posscreen.dart';
import 'package:stockflow/features/products/add_product.dart';
import 'package:stockflow/features/products/product_detail.dart';
import 'package:stockflow/features/products/products_screen.dart';
import 'package:stockflow/features/reports/reports_screen.dart';
import 'package:stockflow/features/splash_screen.dart';
import 'package:stockflow/features/transactions/add_transaction.dart';
import 'package:stockflow/router.dart';
import 'core/theme.dart';

void main() {
  runApp(const StockFlowApp());
}

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp
    // .router
    (
      title: 'StockFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      /// Simple UI entry (no router)
      home: const ProductsScreen(),
      //  PosScreen(),

      // routerConfig: router,
    );
  }
}
