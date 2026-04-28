import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C5CE7);
  static const success = Color(0xFF00B894);
  static const warning = Color(0xFFE17055);
  static const danger = Color(0xFFD63031);
  static const background = Color(0xFFF8F9FA);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const border = Color(0xFFEEEEEE);
}

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const addProduct = '/products/add';
  static const productDetail = '/products/:id';
  static const transactions = '/transactions';
  static const addTransaction = '/transactions/add';
  static const reports = '/reports';
  static const settings = '/settings';
  static const users = '/users';
}

class AppStrings {
  static const appName = 'StockFlow';
  static const tagline = 'Smart Inventory Management';
}
