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
import 'package:stockflow/screens/auth/login_screen.dart';
import 'package:stockflow/screens/dashboard/ashboard_screen.dart';
import 'package:stockflow/screens/products/add_product.dart';
import 'package:stockflow/screens/products/product_detail.dart';
import 'package:stockflow/screens/products/products_screen.dart';
import 'package:stockflow/screens/reports/reports_screen.dart';
import 'package:stockflow/screens/splash_screen.dart';
import 'package:stockflow/screens/transactions/add_transaction.dart';
import 'core/theme.dart';

void main() {
  runApp(const StockFlowApp());
}

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      /// Simple UI entry (no router)
      home: const DashboardScreen(),
    );
  }
}
