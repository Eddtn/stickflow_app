

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockflow/features/auth/lock_screen.dart';
import 'package:stockflow/features/bottom_navigation_screen/bottom_nav_screen.dart';
import 'package:stockflow/features/dashboard/ashboard_screen.dart';
import 'package:stockflow/features/posscreen/posscreen.dart';
import 'package:stockflow/features/products/products_screen.dart';
import 'package:stockflow/features/reports/reports_screen.dart';
import 'package:stockflow/features/setting_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
      // HomePage(),
    ),
    GoRoute(
      path: '/mainscreen',
      builder: (context, state) => const MainScreen(),
      // HomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'loginscreen',
      builder: (context, state) => LockScreen(onAuthenticated: () {}),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        // final email = state.pathParameters['email']!;
        return DashboardScreen();
      },
    ),
    GoRoute(
      path: '/product',
      builder: (context, state) => const ProductsScreen(),
    ),

    GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
    GoRoute(
      path: '/report',
      name: 'reportsScreen',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/setting',
      name: 'settingsscreen',
      builder: (context, state) => SettingsScreen(),

      //  SettingsScreen(
      //   user: {},
      //   role: '',
      //   onUserManagement: () {},
      //   onChangePassword: () {},
      //   onLogout: () {},
      // ),
    ),
  ],
);
