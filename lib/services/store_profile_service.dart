// lib/services/store_profile_service.dart
//
// Central service for reading/writing store profile.
// Import this anywhere you need the store name, VAT rate, etc.

import 'package:shared_preferences/shared_preferences.dart';

class StoreProfileService {
  static final StoreProfileService instance = StoreProfileService._();
  StoreProfileService._();

  static const _kStoreName = 'sf_store_name';
  static const _kStoreAddress = 'sf_store_address';
  static const _kStorePhone = 'sf_store_phone';
  static const _kReceiptFooter = 'sf_receipt_footer';
  static const _kVatRate = 'sf_vat_rate';

  // ── Getters ────────────────────────────────────────────────────────────────
  Future<String> get storeName async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kStoreName) ?? 'My Store';
  }

  Future<String> get storeAddress async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kStoreAddress) ?? '';
  }

  Future<String> get storePhone async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kStorePhone) ?? '';
  }

  Future<String> get receiptFooter async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kReceiptFooter) ?? 'Thank you for your purchase!';
  }

  Future<double> get vatRate async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_kVatRate) ?? 7.5;
  }

  // ── Save all at once ───────────────────────────────────────────────────────
  Future<void> save({
    required String name,
    required String address,
    required String phone,
    required String footer,
    required double vat,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kStoreName, name);
    await p.setString(_kStoreAddress, address);
    await p.setString(_kStorePhone, phone);
    await p.setString(_kReceiptFooter, footer);
    await p.setDouble(_kVatRate, vat);
  }

  // ── Load all at once ───────────────────────────────────────────────────────
  Future<StoreProfile> load() async {
    final p = await SharedPreferences.getInstance();
    return StoreProfile(
      name: p.getString(_kStoreName) ?? 'My Store',
      address: p.getString(_kStoreAddress) ?? '',
      phone: p.getString(_kStorePhone) ?? '',
      footer: p.getString(_kReceiptFooter) ?? 'Thank you for your purchase!',
      vatRate: p.getDouble(_kVatRate) ?? 7.5,
    );
  }
}

class StoreProfile {
  final String name;
  final String address;
  final String phone;
  final String footer;
  final double vatRate;

  const StoreProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.footer,
    required this.vatRate,
  });
}
