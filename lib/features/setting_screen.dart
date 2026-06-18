// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/features/auth/auth_screen.dart';
import 'package:stockflow/features/backUp_screen/backup_screen.dart';
import 'package:stockflow/features/dashboard/sellerScreen.dart';
import 'package:stockflow/features/stock/low_stock_screen.dart';
import 'package:stockflow/services/store_profile_service.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFFF0F4F8);
const _kWhite = Colors.white;
const _kBlue = Color(0xFF0057FF);
const _kGreen = Color(0xFF00C17C);
const _kOrange = Color(0xFFFF8C00);
const _kRed = Color(0xFFE53935);
const _kPurple = Color(0xFF7C3AED);
const _kInk = Color(0xFF0D1B2A);
const _kInkMid = Color(0xFF4A5568);
const _kInkSoft = Color(0xFFCBD5E0);
const _kBorder = Color(0xFFEEF2F7);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _svc = StoreProfileService.instance;

  // controllers
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _footerCtrl = TextEditingController();

  double _vatRate = 7.5;
  bool _lowStockNotif = true;
  bool _authEnabled = false;
  bool _loading = true;
  bool _saving = false;
  bool _profileDirty = false; // true when unsaved changes exist

  @override
  void initState() {
    super.initState();
    _load();
    // Mark dirty whenever any field changes
    for (final c in [_nameCtrl, _addressCtrl, _phoneCtrl, _footerCtrl]) {
      c.addListener(() => setState(() => _profileDirty = true));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await _svc.load();
    final authOn = await AuthService.instance.isAuthEnabled;
    setState(() {
      _nameCtrl.text = profile.name;
      _addressCtrl.text = profile.address;
      _phoneCtrl.text = profile.phone;
      _footerCtrl.text = profile.footer;
      _vatRate = profile.vatRate;
      _authEnabled = authOn;
      _loading = false;
      _profileDirty = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Store name cannot be empty', _kRed);
      return;
    }
    setState(() => _saving = true);
    await _svc.save(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      footer: _footerCtrl.text.trim(),
      vat: _vatRate,
    );
    setState(() {
      _saving = false;
      _profileDirty = false;
    });
    _showSnack('Store profile saved ✅', _kGreen);
  }

  Future<void> _saveVat(double rate) async {
    setState(() {
      _vatRate = rate;
      _profileDirty = true;
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _go(Widget s) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => s),
  ).then((_) => _load());

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        surfaceTintColor: _kWhite,
        foregroundColor: _kInk,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_profileDirty) {
              _showUnsavedDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _kInk,
          ),
        ),
        actions: [
          if (_profileDirty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kBlue,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: _kBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileCard(),
                const SizedBox(height: 20),
                _buildReceiptCard(),
                const SizedBox(height: 20),
                _buildSecurityCard(),
                const SizedBox(height: 20),
                _buildNotifCard(),
                const SizedBox(height: 20),
                _buildDataCard(),

                const SizedBox(height: 20),
                _buildAboutCard(),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  // ── Unsaved changes dialog ─────────────────────────────────────────────────
  Future<void> _showUnsavedDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Unsaved Changes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('You have unsaved changes to your store profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text(
              'Save',
              style: TextStyle(color: _kBlue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (result == 'save') {
      await _saveProfile();
      if (mounted) Navigator.pop(context);
    } else if (result == 'discard') {
      if (mounted) Navigator.pop(context);
    }
  }

  // ── 1. Store Profile Card ──────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _cardHeader(
            icon: Icons.storefront_rounded,
            color: _kBlue,
            title: 'Store Profile',
            subtitle: 'Appears on receipts and barcode labels',
            trailing: _profileDirty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kOrange.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Unsaved',
                      style: TextStyle(
                        color: _kOrange,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.check_circle_rounded,
                    color: _kGreen,
                    size: 18,
                  ),
          ),

          const SizedBox(height: 16),

          // Store name — most important, bigger
          _fieldLabel('Store Name *'),
          const SizedBox(height: 6),
          _textField(
            controller: _nameCtrl,
            hint: 'e.g. Chinedu Superstore',
            icon: Icons.store_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),

          _fieldLabel('Address'),
          const SizedBox(height: 6),
          _textField(
            controller: _addressCtrl,
            hint: 'e.g. 12 Market Road, Lagos',
            icon: Icons.location_on_rounded,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),

          _fieldLabel('Phone Number'),
          const SizedBox(height: 6),
          _textField(
            controller: _phoneCtrl,
            hint: 'e.g. 08012345678',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 14),

          _fieldLabel('Receipt Footer Message'),
          const SizedBox(height: 6),
          _textField(
            controller: _footerCtrl,
            hint: 'e.g. Thank you for shopping with us!',
            icon: Icons.message_rounded,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),

          // Live preview
          _buildReceiptPreview(),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (_saving || !_profileDirty) ? null : _saveProfile,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(_saving ? 'Saving…' : 'Save Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _profileDirty ? _kBlue : _kInkSoft,
                disabledBackgroundColor: _kInkSoft,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Receipt mini-preview ───────────────────────────────────────────────────
  Widget _buildReceiptPreview() {
    final name = _nameCtrl.text.trim().isEmpty
        ? 'My Store'
        : _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final footer = _footerCtrl.text.trim().isEmpty
        ? 'Thank you for your purchase!'
        : _footerCtrl.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 13, color: _kInkMid),
              const SizedBox(width: 6),
              const Text(
                'Receipt Preview',
                style: TextStyle(
                  color: _kInkMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: _kGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: _kBorder),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: _kInk,
              letterSpacing: 1.5,
            ),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              address,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kInkMid, fontSize: 11),
            ),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Tel: $phone',
              style: const TextStyle(color: _kInkMid, fontSize: 11),
            ),
          ],
          const Divider(height: 16, color: _kBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Rice 5kg  × 2',
                style: TextStyle(fontSize: 11, color: _kInk),
              ),
              Text(
                '₦29,000',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VAT',
                style: TextStyle(fontSize: 11, color: _kInkMid),
              ),
              Text(
                '${_vatRate.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11, color: _kInkMid),
              ),
            ],
          ),
          const Divider(height: 12, color: _kBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: _kInk,
                ),
              ),
              Text(
                '₦31,175',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: _kBlue,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: _kBorder),
          Text(
            footer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kInkMid,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Receipt / VAT ───────────────────────────────────────────────────────
  Widget _buildReceiptCard() {
    final vatOptions = [0.0, 5.0, 7.5, 10.0, 15.0];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            icon: Icons.receipt_long_rounded,
            color: _kPurple,
            title: 'VAT Rate',
            subtitle: 'Applied to every sale receipt',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vatOptions.map((rate) {
              final selected = _vatRate == rate;
              return GestureDetector(
                onTap: () => _saveVat(rate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _kPurple : _kBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: selected ? _kPurple : _kInkSoft),
                  ),
                  child: Text(
                    rate == 0 ? 'No VAT' : '${rate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: selected ? Colors.white : _kInkMid,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            _vatRate == 0
                ? 'No VAT will be added to receipts'
                : '${_vatRate.toStringAsFixed(1)}% VAT will be added to every receipt',
            style: const TextStyle(color: _kInkMid, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── 3. Security ────────────────────────────────────────────────────────────
  Widget _buildSecurityCard() => _card(
    child: Column(
      children: [
        _cardHeader(
          icon: Icons.security_rounded,
          color: const Color(0xFF555FDD),
          title: 'Security',
          subtitle: 'App lock and authentication',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (_authEnabled ? _kGreen : _kRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _authEnabled ? 'ON' : 'OFF',
              style: TextStyle(
                color: _authEnabled ? _kGreen : _kRed,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _tileRow(
          icon: Icons.lock_rounded,
          label: 'App Lock & Passcode',
          color: const Color(0xFF555FDD),
          onTap: () => _go(const AuthSetupScreen()),
        ),
        const Divider(height: 1, color: _kBorder),
        _tileRow(
          icon: Icons.fingerprint_rounded,
          label: 'Biometric Authentication',
          color: const Color(0xFF555FDD),
          onTap: () => _go(const AuthSetupScreen()),
        ),
      ],
    ),
  );

  // ── 4. Notifications ───────────────────────────────────────────────────────
  Widget _buildNotifCard() => _card(
    child: Column(
      children: [
        _cardHeader(
          icon: Icons.notifications_rounded,
          color: _kOrange,
          title: 'Notifications',
          subtitle: 'Low stock and sale alerts',
        ),
        const SizedBox(height: 8),
        _tileRow(
          icon: Icons.tune_rounded,
          label: 'Configure Stock Thresholds',
          color: _kOrange,
          onTap: () => _go(const LowStockScreen()),
        ),
      ],
    ),
  );

  // ── 5. Data ────────────────────────────────────────────────────────────────
  Widget _buildDataCard() => _card(
    child: Column(
      children: [
        _cardHeader(
          icon: Icons.storage_rounded,
          color: _kGreen,
          title: 'Data Management',
          subtitle: 'Backup, export and clear data',
        ),
        const SizedBox(height: 8),
        _tileRow(
          icon: Icons.backup_rounded,
          label: 'Backup & Export',
          color: _kGreen,
          onTap: () => _go(const BackupScreen()),
        ),
        const Divider(height: 1, color: _kBorder),
        _tileRow(
          icon: Icons.delete_sweep_rounded,
          label: 'Clear Sales History',
          color: _kRed,
          onTap: _confirmClearSales,
        ),
        _tileRow(
          icon: Icons.people_rounded,
          label: 'Manage Cashiers',
          color: const Color(0xFF0057FF),
          onTap: () => _go(const SellersScreen()),
        ),
      ],
    ),
  );

  Future<void> _confirmClearSales() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Clear Sales History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This permanently deletes all sales records.\nProducts and inventory are not affected.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('sale_items');
      await db.delete('sales');
      _showSnack('Sales history cleared', _kRed);
    }
  }

  // ── 6. About ───────────────────────────────────────────────────────────────
  Widget _buildAboutCard() => _card(
    child: Column(
      children: [
        _cardHeader(
          icon: Icons.info_rounded,
          color: _kInkMid,
          title: 'About StockFlow',
          subtitle: 'Version and app information',
        ),
        const SizedBox(height: 8),
        _infoRow('Version', '1.0.0'),
        const Divider(height: 1, color: _kBorder),
        _infoRow('Database', 'SQLite — 100% Offline'),
        const Divider(height: 1, color: _kBorder),
        _infoRow('Built with', 'Flutter'),
        const Divider(height: 1, color: _kBorder),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: const [
              Icon(Icons.favorite_rounded, color: _kRed, size: 15),
              SizedBox(width: 8),
              Text(
                'Built for Nigerian businesses',
                style: TextStyle(color: _kInkMid, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Widget helpers ─────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kWhite,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _cardHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _kInk,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: _kInkMid, fontSize: 11),
            ),
          ],
        ),
      ),
      if (trailing != null) trailing,
    ],
  );

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: _kInkMid,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    inputFormatters: inputFormatters,
    style: const TextStyle(color: _kInk, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kInkSoft, fontSize: 14),
      prefixIcon: Icon(icon, color: _kInkMid, size: 18),
      filled: true,
      fillColor: _kBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _kBlue.withOpacity(0.5), width: 1.5),
      ),
    ),
  );

  Widget _tileRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _kInk,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: _kInkSoft, size: 20),
        ],
      ),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _kInkMid, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
