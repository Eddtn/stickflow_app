import 'package:flutter/material.dart';
import 'package:stockflow/features/auth/lock_screen.dart';
import 'package:stockflow/features/auth/seller_login_screen.dart';
import 'package:stockflow/features/bottom_navigation_screen/bottom_nav_screen.dart';
import 'package:stockflow/features/dashboard/ashboard_screen.dart';
import 'package:stockflow/features/dashboard/sellerScreen.dart';
import 'package:stockflow/features/products/product_detail.dart';
import 'package:stockflow/features/reports/reports_screen.dart';
import 'package:stockflow/services/notification/notification_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const StockFlowApp());
}

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockFlow',
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

// AuthGate checks if lock is enabled and shows LockScreen or Dashboard
class _AuthGate extends StatefulWidget {
  const _AuthGate();
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;
  bool _needsAuth = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final enabled = await AuthService.instance.isAuthEnabled;
    setState(() {
      _checking = false;
      _needsAuth = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F1E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066FF)),
        ),
      );
    }

    if (_needsAuth) {
      return LockScreen(
        onAuthenticated: () => setState(() => _needsAuth = false),
      );
    }
    // After lock screen passes (or if no lock), show seller login:
    return const SellerLoginScreen();

    // if (_needsAuth) {
    //   return LockScreen(
    //     onAuthenticated: () => setState(() => _needsAuth = false),
    //   );
    // }

    // return const SellerLoginScreen();

    // if (_needsAuth) {
    //   return LockScreen(
    //     onAuthenticated: () => setState(() => _needsAuth = false),
    //   );
    // }
    // return const MainScreen();
    // // DashboardScreen();
  }
}
