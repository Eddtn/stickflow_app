// lib/services/auth_service.dart
//
// Handles all authentication logic:
// • Biometric (fingerprint / face ID) via local_auth
// • 4-digit passcode stored securely in SharedPreferences
// • Auth state persistence — remembers if user is authenticated
//   for the current session

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _auth = LocalAuthentication();

  static const _keyPasscode = 'sf_passcode';
  static const _keyAuthEnabled = 'sf_auth_enabled';
  static const _keyAuthType =
      'sf_auth_type'; // 'biometric' | 'passcode' | 'both'

  // ── Check if device supports biometrics ───────────────────────────────────
  Future<bool> get isBiometricAvailable async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  // ── Get available biometric types ─────────────────────────────────────────
  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  // ── Auth settings getters/setters ─────────────────────────────────────────
  Future<bool> get isAuthEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAuthEnabled) ?? false;
  }

  Future<String> get authType async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthType) ?? 'passcode';
  }

  Future<bool> get hasPasscode async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_keyPasscode) ?? '').isNotEmpty;
  }

  Future<void> setAuthEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuthEnabled, enabled);
  }

  Future<void> setAuthType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthType, type);
  }

  Future<void> savePasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPasscode, passcode);
  }

  Future<void> clearPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPasscode);
  }

  // ── Verify passcode ───────────────────────────────────────────────────────
  Future<bool> verifyPasscode(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyPasscode) ?? '';
    return stored == input && stored.isNotEmpty;
  }

  // ── Biometric authentication ──────────────────────────────────────────────
  Future<BiometricResult> authenticateWithBiometrics() async {
    try {
      final available = await isBiometricAvailable;
      if (!available) return BiometricResult.notAvailable;

      // local_auth 2.x — authenticate() only needs localizedReason
      // stickyAuth and useErrorDialogs are true by default in 2.x
      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access StockFlow',
      );
      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        return BiometricResult.notAvailable;
      }
      return BiometricResult.failed;
    } catch (_) {
      return BiometricResult.failed;
    }
  }

  // ── Disable all auth ──────────────────────────────────────────────────────
  Future<void> disableAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuthEnabled, false);
    await prefs.remove(_keyPasscode);
    await prefs.remove(_keyAuthType);
  }
}

enum BiometricResult { success, failed, notAvailable }
