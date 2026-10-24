import 'package:flutter/material.dart';

class AppColors {
  // ── Core brand ───────────────────────────────────────────────────────────
  static const primary = Color(0xFF0057FF);
  static const primarySoft = Color(0xFFEBF1FF);

  // ── Status / accent colors ───────────────────────────────────────────────
  static const success = Color(0xFF00C17C);
  static const successSoft = Color(0xFFE6FAF3);

  static const warning = Color(0xFFFF8C00);
  static const warningSoft = Color(0xFFFFF3E0);

  static const danger = Color(0xFFE53935);
  static const dangerSoft = Color(0xFFFDEBEA);

  static const accentPurple = Color(0xFF7C3AED);
  static const accentPurpleSoft = Color(0xFFF3EDFF);

  static const accentTeal = Color(0xFF0099AA);
  static const accentPink = Color(0xFFFF5370);
  static const accentCyan = Color(0xFF00BCD4);

  // Cycling colors for avatars/lists (e.g. seller avatars)
  static const avatarColors = [
    primary,
    success,
    warning,
    accentPurple,
    accentPink,
    accentCyan,
  ];

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const background = Color(0xFFF4F7FB);
  static const cardBg = Colors.white;
  static const border = Color(0xFFEEF2F7);

  // ── Text / ink ───────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF4A5568);
  static const textSoft = Color(0xFFCBD5E0);
}

/// Dark palette used by the security / passcode-lock flow
/// (auth_setup_screen.dart, lock_screen.dart, etc.)
class AppDarkColors {
  static const bg = Color(0xFF0A0F1E);
  static const surface = Color(0xFF141B2D);
  static const card = Color(0xFF1C2539);
  static const accent = Color(0xFF00E5A0);
  static const accentDim = Color(0xFF00B87A);
  static const blue = Color(0xFF0066FF);
  static const danger = Color(0xFFFF5370);
  static const warning = Color(0xFFFFB547);
  static const text = Color(0xFFEEF2FF);
  static const textDim = Color(0xFF8892A4);

  // Extra accents used for seller/avatar color-cycling
  static const pink = Color(0xFFFF85A2);
  static const lightBlue = Color(0xFF7C9FFF);
  static const lightPurple = Color(0xFFB47FFF);
  static const skyBlue = Color(0xFF4FC3F7);
  static const cyan = Color(0xFF4FC3F7);

  static const avatarColors = [
    blue,
    accent,
    warning,
    pink,
    lightBlue,
    lightPurple,
  ];
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
