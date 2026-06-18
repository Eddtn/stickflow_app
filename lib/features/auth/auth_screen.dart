// lib/screens/auth_setup_screen.dart
//
// Security Settings screen.
// • Enable / disable app lock
// • Choose auth method: Biometric, Passcode, or Both
// • Set / change / remove passcode
// • Test authentication

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:stockflow/services/auth_service.dart';
import 'lock_screen.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kBlue = Color(0xFF0066FF);
const _kDanger = Color(0xFFFF5370);
const _kWarning = Color(0xFFFFB547);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

class AuthSetupScreen extends StatefulWidget {
  const AuthSetupScreen({super.key});

  @override
  State<AuthSetupScreen> createState() => _AuthSetupScreenState();
}

class _AuthSetupScreenState extends State<AuthSetupScreen> {
  final _svc = AuthService.instance;

  bool _authEnabled = false;
  String _authType = 'passcode';
  bool _bioAvailable = false;
  bool _hasPasscode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _svc.isAuthEnabled;
    final type = await _svc.authType;
    final bio = await _svc.isBiometricAvailable;
    final hasPc = await _svc.hasPasscode;
    setState(() {
      _authEnabled = enabled;
      _authType = type;
      _bioAvailable = bio;
      _hasPasscode = hasPc;
      _loading = false;
    });
  }

  // ── Toggle auth on/off ────────────────────────────────────────────────────
  Future<void> _toggleAuth(bool value) async {
    if (value) {
      // Must set up passcode first if enabling
      if (!_hasPasscode) {
        final ok = await _showPasscodeSetup(isNew: true);
        if (!ok) return;
      }
      await _svc.setAuthEnabled(true);
      setState(() => _authEnabled = true);
      _showSnack('App lock enabled ✅', _kAccent);
    } else {
      // Confirm before disabling
      final confirm = await _confirmDialog(
        title: 'Disable App Lock',
        message:
            'Anyone with access to this device will be able to open StockFlow. Disable anyway?',
        confirmLabel: 'Disable',
        confirmColor: _kDanger,
      );
      if (confirm != true) return;
      await _svc.disableAuth();
      setState(() {
        _authEnabled = false;
        _hasPasscode = false;
      });
      _showSnack('App lock disabled', _kWarning);
    }
  }

  // ── Set auth type ─────────────────────────────────────────────────────────
  Future<void> _setAuthType(String type) async {
    await _svc.setAuthType(type);
    setState(() => _authType = type);
  }

  // ── Passcode setup flow ───────────────────────────────────────────────────
  Future<bool> _showPasscodeSetup({bool isNew = false}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PasscodeSetupSheet(isNew: isNew),
    );
    if (result == true) {
      setState(() => _hasPasscode = true);
      return true;
    }
    return false;
  }

  // ── Change passcode ───────────────────────────────────────────────────────
  Future<void> _changePasscode() async {
    if (_hasPasscode) {
      // Verify current passcode first
      final verified = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _PasscodeVerifySheet(),
      );
      if (verified != true) return;
    }
    await _showPasscodeSetup(isNew: false);
    _showSnack('Passcode updated ✅', _kAccent);
  }

  // ── Remove passcode ───────────────────────────────────────────────────────
  Future<void> _removePasscode() async {
    final confirm = await _confirmDialog(
      title: 'Remove Passcode',
      message: 'This will also disable biometric auth if enabled.',
      confirmLabel: 'Remove',
      confirmColor: _kDanger,
    );
    if (confirm != true) return;
    await _svc.disableAuth();
    setState(() {
      _hasPasscode = false;
      _authEnabled = false;
    });
    _showSnack('Passcode removed', _kWarning);
  }

  // ── Test auth ─────────────────────────────────────────────────────────────
  void _testAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LockScreen(
          onAuthenticated: () {
            Navigator.pop(context);
            _showSnack('Authentication successful! 🎉', _kAccent);
          },
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _kBg),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _kTextDim,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Security',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _kAccent))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBanner(),
                  const SizedBox(height: 20),
                  _buildMainToggle(),
                  if (_authEnabled) ...[
                    const SizedBox(height: 20),
                    _buildAuthTypeSection(),
                    const SizedBox(height: 20),
                    _buildPasscodeSection(),
                    const SizedBox(height: 20),
                    _buildTestButton(),
                  ],
                ],
              ),
      ),
    );
  }

  // ── Security banner ───────────────────────────────────────────────────────
  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [_kBlue.withOpacity(0.15), _kAccent.withOpacity(0.08)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _kBlue.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _kBlue.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _authEnabled ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: _authEnabled ? _kAccent : _kTextDim,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _authEnabled ? 'App Lock is ON' : 'App Lock is OFF',
                style: TextStyle(
                  color: _authEnabled ? _kAccent : _kTextDim,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _authEnabled
                    ? 'StockFlow is protected. Authentication required on every open.'
                    : 'Enable app lock to protect your business data.',
                style: const TextStyle(
                  color: _kTextDim,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Main toggle ───────────────────────────────────────────────────────────
  Widget _buildMainToggle() => _card(
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (_authEnabled ? _kAccent : _kTextDim).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.security_rounded,
            color: _authEnabled ? _kAccent : _kTextDim,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Lock',
                style: TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Require authentication to open StockFlow',
                style: TextStyle(color: _kTextDim, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: _authEnabled,
          onChanged: _toggleAuth,
          activeColor: _kAccent,
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _kAccent.withOpacity(0.3)
                : Colors.white12,
          ),
        ),
      ],
    ),
  );

  // ── Auth type ─────────────────────────────────────────────────────────────
  Widget _buildAuthTypeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('AUTHENTICATION METHOD'),
      const SizedBox(height: 8),
      _card(
        child: Column(
          children: [
            _authTypeOption(
              icon: Icons.pin_rounded,
              label: 'Passcode only',
              subtitle: '4-digit PIN',
              value: 'passcode',
            ),
            if (_bioAvailable) ...[
              const Divider(color: Colors.white10, height: 1),
              _authTypeOption(
                icon: Icons.fingerprint_rounded,
                label: 'Biometric only',
                subtitle: 'Fingerprint or Face ID',
                value: 'biometric',
              ),
              const Divider(color: Colors.white10, height: 1),
              _authTypeOption(
                icon: Icons.verified_user_rounded,
                label: 'Biometric + Passcode',
                subtitle: 'Try biometric first, fallback to PIN',
                value: 'both',
              ),
            ],
            if (!_bioAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: _kTextDim,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Biometric not available on this device',
                        style: TextStyle(color: _kTextDim, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _authTypeOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required String value,
  }) {
    final selected = _authType == value;
    return GestureDetector(
      onTap: () => _setAuthType(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: selected ? _kAccent : _kTextDim, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? _kText : _kTextDim,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _kTextDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _kAccent : Colors.transparent,
                border: Border.all(
                  color: selected ? _kAccent : _kTextDim,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Passcode section ──────────────────────────────────────────────────────
  Widget _buildPasscodeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('PASSCODE'),
      const SizedBox(height: 8),
      _card(
        child: Column(
          children: [
            _settingsRow(
              icon: Icons.edit_rounded,
              label: _hasPasscode ? 'Change Passcode' : 'Set Passcode',
              color: _kAccent,
              onTap: _changePasscode,
            ),
            if (_hasPasscode) ...[
              const Divider(color: Colors.white10, height: 1),
              _settingsRow(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Passcode',
                color: _kDanger,
                onTap: _removePasscode,
              ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _settingsRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ── Test button ───────────────────────────────────────────────────────────
  Widget _buildTestButton() => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton.icon(
      onPressed: _testAuth,
      icon: const Icon(Icons.play_arrow_rounded, color: _kAccent),
      label: const Text(
        'Test Authentication',
        style: TextStyle(color: _kAccent, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _kAccent.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: child,
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: _kTextDim,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(color: _kText, fontWeight: FontWeight.w700),
      ),
      content: Text(
        message,
        style: const TextStyle(color: _kTextDim, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: _kTextDim)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  PASSCODE SETUP SHEET
// ─────────────────────────────────────────────
class _PasscodeSetupSheet extends StatefulWidget {
  final bool isNew;
  const _PasscodeSetupSheet({required this.isNew});

  @override
  State<_PasscodeSetupSheet> createState() => _PasscodeSetupSheetState();
}

class _PasscodeSetupSheetState extends State<_PasscodeSetupSheet> {
  String _first = '';
  String _second = '';
  bool _confirming = false;
  String _error = '';

  void _onKey(String k) {
    HapticFeedback.lightImpact();
    if (!_confirming) {
      if (_first.length >= 4) return;
      setState(() {
        _first += k;
        _error = '';
      });
      if (_first.length == 4) {
        setState(() => _confirming = true);
      }
    } else {
      if (_second.length >= 4) return;
      setState(() {
        _second += k;
        _error = '';
      });
      if (_second.length == 4) _save();
    }
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    if (_confirming) {
      if (_second.isEmpty) {
        setState(() {
          _confirming = false;
          _first = '';
        });
      } else {
        setState(() => _second = _second.substring(0, _second.length - 1));
      }
    } else {
      if (_first.isNotEmpty) {
        setState(() => _first = _first.substring(0, _first.length - 1));
      }
    }
  }

  Future<void> _save() async {
    if (_first != _second) {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'Passcodes do not match. Try again.';
        _second = '';
        _confirming = false;
        _first = '';
      });
      return;
    }
    await AuthService.instance.savePasscode(_first);
    if (mounted) Navigator.pop(context, true);
  }

  String get _activeInput => _confirming ? _second : _first;
  String get _prompt =>
      _confirming ? 'Confirm your passcode' : 'Enter a new passcode';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _prompt,
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 24),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _activeInput.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? _kAccent : Colors.transparent,
                  border: Border.all(
                    color: filled ? _kAccent : _kTextDim,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_error, style: const TextStyle(color: _kDanger, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          // Keypad
          ...[
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', 'del'],
          ].map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((k) {
                  if (k.isEmpty) return const SizedBox(width: 64, height: 64);
                  return GestureDetector(
                    onTap: k == 'del' ? _onDelete : () => _onKey(k),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _kCard,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: k == 'del'
                            ? const Icon(
                                Icons.backspace_outlined,
                                color: _kTextDim,
                                size: 20,
                              )
                            : Text(
                                k,
                                style: const TextStyle(
                                  color: _kText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PASSCODE VERIFY SHEET (for change passcode)
// ─────────────────────────────────────────────
class _PasscodeVerifySheet extends StatefulWidget {
  @override
  State<_PasscodeVerifySheet> createState() => _PasscodeVerifySheetState();
}

class _PasscodeVerifySheetState extends State<_PasscodeVerifySheet> {
  String _input = '';
  String _error = '';

  void _onKey(String k) {
    HapticFeedback.lightImpact();
    if (_input.length >= 4) return;
    setState(() {
      _input += k;
      _error = '';
    });
    if (_input.length == 4) _verify();
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    if (_input.isNotEmpty) {
      setState(() => _input = _input.substring(0, _input.length - 1));
    }
  }

  Future<void> _verify() async {
    final ok = await AuthService.instance.verifyPasscode(_input);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'Wrong passcode';
        _input = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Enter current passcode',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _input.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? _kAccent : Colors.transparent,
                  border: Border.all(
                    color: filled ? _kAccent : _kTextDim,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_error, style: const TextStyle(color: _kDanger, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          ...[
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', 'del'],
          ].map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((k) {
                  if (k.isEmpty) return const SizedBox(width: 64, height: 64);
                  return GestureDetector(
                    onTap: k == 'del' ? _onDelete : () => _onKey(k),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _kCard,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: k == 'del'
                            ? const Icon(
                                Icons.backspace_outlined,
                                color: _kTextDim,
                                size: 20,
                              )
                            : Text(
                                k,
                                style: const TextStyle(
                                  color: _kText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
