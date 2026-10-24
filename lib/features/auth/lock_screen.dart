
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:stockflow/core/constant.dart';
import 'package:stockflow/services/auth_service.dart';

class LockScreen extends StatefulWidget {
  /// Called when authentication succeeds
  final VoidCallback onAuthenticated;
  const LockScreen({super.key, required this.onAuthenticated});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  final _svc = AuthService.instance;

  String _input = '';
  String _message = '';
  bool _hasError = false;
  bool _showBio = false;
  bool _checking = false;
  int _attempts = 0;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _init();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final type = await _svc.authType;
    final bioAvail = await _svc.isBiometricAvailable;
    setState(() {
      _showBio = bioAvail && (type == 'biometric' || type == 'both');
    });
    // Auto-trigger biometric if that's the primary method
    if (_showBio && (type == 'biometric' || type == 'both')) {
      await Future.delayed(const Duration(milliseconds: 400));
      _tryBiometric();
    }
  }

  // ── Biometric ─────────────────────────────────────────────────────────────
  Future<void> _tryBiometric() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _message = '';
    });
    final result = await _svc.authenticateWithBiometrics();
    if (!mounted) return;
    setState(() => _checking = false);

    if (result == BiometricResult.success) {
      _onSuccess();
    } else if (result == BiometricResult.notAvailable) {
      setState(() => _message = 'Biometrics not available. Use passcode.');
    }
  }

  // ── Passcode input ────────────────────────────────────────────────────────
  void _onKey(String key) {
    if (_input.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _input += key;
      _message = '';
      _hasError = false;
    });
    if (_input.length == 4) _verifyPasscode();
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _verifyPasscode() async {
    final ok = await _svc.verifyPasscode(_input);
    if (!mounted) return;
    if (ok) {
      _onSuccess();
    } else {
      _attempts++;
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _input = '';
        _message = _attempts >= 5
            ? 'Too many attempts. Try biometrics or contact admin.'
            : 'Wrong passcode. ${5 - _attempts} attempts left.';
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  void _onSuccess() {
    HapticFeedback.mediumImpact();
    widget.onAuthenticated();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppDarkColors.bg,
      ),
      child: Scaffold(
        backgroundColor: AppDarkColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildDots(),
              const SizedBox(height: 16),
              _buildMessage(),
              const Spacer(),
              _buildKeypad(),
              const SizedBox(height: 32),
              if (_showBio) _buildBioButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────────────
  Widget _buildLogo() => Column(
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0044DD), Color(0xFF0099FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppDarkColors.blue.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.storefront_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'StockFlow',
        style: TextStyle(
          color: AppDarkColors.text,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Enter your passcode to continue',
        style: TextStyle(color: AppDarkColors.textDim, fontSize: 14),
      ),
    ],
  );

  // ── Passcode dots ──────────────────────────────────────────────────────────
  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = math.sin(_shakeAnim.value * math.pi * 6) * 10;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final filled = i < _input.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? (_hasError ? AppDarkColors.danger : AppDarkColors.blue)
                  : Colors.transparent,
              border: Border.all(
                color: filled
                    ? (_hasError ? AppDarkColors.danger : AppDarkColors.blue)
                    : AppDarkColors.textDim,
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Message ────────────────────────────────────────────────────────────────
  Widget _buildMessage() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    child: _message.isEmpty
        ? const SizedBox(height: 20, key: ValueKey('empty'))
        : Container(
            key: ValueKey(_message),
            height: 20,
            child: Text(
              _message,
              style: TextStyle(
                color: _hasError ? AppDarkColors.danger : AppDarkColors.textDim,
                fontSize: 13,
              ),
            ),
          ),
  );

  // ── Keypad ────────────────────────────────────────────────────────────────
  Widget _buildKeypad() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: keys
            .map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((key) {
                    if (key.isEmpty)
                      return const SizedBox(width: 72, height: 72);
                    return _keyButton(key);
                  }).toList(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _keyButton(String key) {
    final isDel = key == 'del';
    return GestureDetector(
      onTap: isDel ? _onDelete : () => _onKey(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppDarkColors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isDel
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppDarkColors.textDim,
                  size: 22,
                )
              : Text(
                  key,
                  style: const TextStyle(
                    color: AppDarkColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Biometric button ───────────────────────────────────────────────────────
  Widget _buildBioButton() => GestureDetector(
    onTap: _tryBiometric,
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppDarkColors.blue.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppDarkColors.blue.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: _checking
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: AppDarkColors.blue,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.fingerprint_rounded,
                  color: AppDarkColors.blue,
                  size: 30,
                ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use Fingerprint',
          style: TextStyle(color: AppDarkColors.textDim, fontSize: 13),
        ),
      ],
    ),
  );
}
