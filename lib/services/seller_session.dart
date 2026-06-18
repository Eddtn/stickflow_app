// lib/services/seller_session.dart
//
// Holds the currently logged-in seller for the session.
// Used throughout the app to check permissions.

import '../models/seller.dart';

class SellerSession {
  static final SellerSession instance = SellerSession._();
  SellerSession._();

  Seller? _current;

  Seller? get current => _current;
  bool get isLoggedIn => _current != null;
  bool get isOwner => _current?.isOwner ?? false;
  bool get isCashier => _current != null && !_current!.isOwner;
  String get sellerName => _current?.name ?? 'Owner';
  int? get sellerId => _current?.id;

  void login(Seller seller) => _current = seller;
  void logout() => _current = null;

  // ── Permission checks ──────────────────────────────────────────────────────
  bool get canViewDashboard => isOwner;
  bool get canViewReports => isOwner;
  bool get canViewAllSales => isOwner;
  bool get canManageProducts => isOwner;
  bool get canManageCashiers => isOwner;
  bool get canAccessSettings => isOwner;
  bool get canAccessBackup => isOwner;
  bool get canStockIn => isOwner;
  bool get canGenerateLabels => isOwner;
  bool get canViewLowStock => isOwner;
  bool get canUsePOS => true; // everyone
  bool get canViewOwnSales => true; // everyone
}
