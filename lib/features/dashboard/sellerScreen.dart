// lib/screens/sellers_screen.dart
//
// Sellers / Cashier Management Screen
// • View all cashiers with today's sales stats
// • Add new cashier with name + 4-digit PIN
// • Edit name, role or PIN
// • Deactivate a cashier (keeps their sales records)
// • Tap any cashier to see their full sales breakdown

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/models/seller.dart';

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

// avatar colours cycling per seller index
const _kAvatarColors = [
  _kBlue,
  _kGreen,
  _kOrange,
  _kPurple,
  Color(0xFFFF5370),
  Color(0xFF00BCD4),
];

// ─────────────────────────────────────────────
//  SELLERS SCREEN
// ─────────────────────────────────────────────
class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  final _db = DatabaseHelper.instance;
  final _fmt = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  List<Seller> _sellers = [];
  Map<int, Map<String, dynamic>> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _db.getAllSellers();
      final sellers = rows.map(Seller.fromMap).toList();

      // load today's stats for every seller
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final stats = <int, Map<String, dynamic>>{};
      for (final s in sellers) {
        if (s.id != null) {
          stats[s.id!] = await _db.getSellerSummary(
            s.id!,
            from: today,
            to: now,
          );
        }
      }

      setState(() {
        _sellers = sellers;
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      debugPrint('SellersScreen _load error: $e');
      setState(() => _loading = false);
    }
  }

  // ── Open add / edit form ───────────────────────────────────────────────────
  Future<void> _openForm({Seller? seller}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SellerFormSheet(seller: seller),
    );
    if (saved == true) _load();
  }

  // ── Deactivate seller ──────────────────────────────────────────────────────
  Future<void> _deactivate(Seller s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Remove Cashier',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${s.name}" from the cashier list?\n\n'
          'Their past sales records will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deactivateSeller(s.id!);
      _load();
    }
  }

  // ── Open detail sheet ──────────────────────────────────────────────────────
  void _openDetail(Seller s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SellerDetailSheet(
        seller: s,
        avatarColor:
            _kAvatarColors[_sellers.indexOf(s) % _kAvatarColors.length],
      ),
    );
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cashiers',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _kInk,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _openForm(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _kBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kBlue))
          : _sellers.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              color: _kBlue,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 16),
                  ..._sellers.map(_buildSellerCard),
                ],
              ),
            ),
    );
  }

  // ── Summary strip ──────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    final totalRevenue = _stats.values.fold<double>(
      0,
      (s, v) => s + ((v['total_revenue'] ?? 0.0) as double),
    );
    final totalOrders = _stats.values.fold<int>(
      0,
      (s, v) => s + ((v['transaction_count'] ?? 0) as int),
    );

    return Row(
      children: [
        _chip('${_sellers.length}', 'Cashiers', Icons.people_rounded, _kBlue),
        const SizedBox(width: 10),
        _chip(
          '$totalOrders',
          "Today's Sales",
          Icons.receipt_long_rounded,
          _kGreen,
        ),
        const SizedBox(width: 10),
        _chip(
          totalRevenue >= 1000000
              ? '₦${(totalRevenue / 1000000).toStringAsFixed(1)}M'
              : totalRevenue >= 1000
              ? '₦${(totalRevenue / 1000).toStringAsFixed(0)}k'
              : '₦${totalRevenue.toStringAsFixed(0)}',
          "Today's Revenue",
          Icons.payments_rounded,
          _kPurple,
        ),
      ],
    );
  }

  Widget _chip(String value, String label, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: _kInkMid, fontSize: 10),
              ),
            ],
          ),
        ),
      );

  // ── Seller card ────────────────────────────────────────────────────────────
  Widget _buildSellerCard(Seller s) {
    final idx = _sellers.indexOf(s);
    final color = _kAvatarColors[idx % _kAvatarColors.length];
    final initials = _initials(s.name);
    final stats = _stats[s.id] ?? {};
    final revenue = (stats['total_revenue'] ?? 0.0) as double;
    final orders = (stats['transaction_count'] ?? 0) as int;

    return GestureDetector(
      onTap: () => _openDetail(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.35), width: 2),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _kInk,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _roleBadge(s, color),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statLabel(
                        Icons.receipt_outlined,
                        '$orders sale${orders == 1 ? '' : 's'} today',
                        _kInkMid,
                      ),
                      const SizedBox(width: 12),
                      _statLabel(
                        Icons.payments_outlined,
                        _fmt.format(revenue),
                        _kGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit / remove buttons
            Row(
              children: [
                _iconBtn(
                  Icons.edit_rounded,
                  _kBlue,
                  () => _openForm(seller: s),
                ),
                const SizedBox(width: 8),
                _iconBtn(Icons.person_off_rounded, _kRed, () => _deactivate(s)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(Seller s, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      s.isOwner ? 'Owner' : 'Cashier',
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );

  Widget _statLabel(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      );

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: _kBlue,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No cashiers yet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add cashiers so you can track\nwho sold what in your store.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kInkMid, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => _openForm(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: _kBlue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _kBlue.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Add First Cashier',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _initials(String name) => name
      .trim()
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();
}

// ─────────────────────────────────────────────
//  ADD / EDIT FORM SHEET
// ─────────────────────────────────────────────
class _SellerFormSheet extends StatefulWidget {
  final Seller? seller;
  const _SellerFormSheet({this.seller});

  @override
  State<_SellerFormSheet> createState() => _SellerFormSheetState();
}

class _SellerFormSheetState extends State<_SellerFormSheet> {
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  String _role = 'cashier';
  bool _saving = false;
  bool _pinVisible = false;
  String _error = '';

  bool get _isEditing => widget.seller != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.seller!.name;
      _pinCtrl.text = widget.seller!.pin;
      _role = widget.seller!.role;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name');
      return;
    }
    if (pin.length != 4) {
      setState(() => _error = 'PIN must be exactly 4 digits');
      return;
    }

    setState(() {
      _saving = true;
      _error = '';
    });

    final seller = Seller(
      id: widget.seller?.id,
      name: name,
      pin: pin,
      role: _role,
    );

    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateSeller(seller.toMap());
      } else {
        await DatabaseHelper.instance.insertSeller(seller.toMap());
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Error saving cashier. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kInkSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _isEditing ? 'Edit Cashier' : 'Add New Cashier',
              style: const TextStyle(
                color: _kInk,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEditing
                  ? 'Update details for ${widget.seller!.name}'
                  : 'Fill in the details below',
              style: const TextStyle(color: _kInkMid, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // ── Name ───────────────────────────────────────────────────────
            _fieldLabel('Full Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: _kInk, fontSize: 14),
              decoration: _inputDecor(
                hint: 'e.g. Amaka Okafor',
                icon: Icons.person_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // ── Role ───────────────────────────────────────────────────────
            _fieldLabel('Role'),
            const SizedBox(height: 8),
            Row(
              children: [
                _roleChip('cashier', 'Cashier', Icons.point_of_sale_rounded),
                const SizedBox(width: 10),
                _roleChip('owner', 'Owner', Icons.admin_panel_settings_rounded),
              ],
            ),
            const SizedBox(height: 16),

            // ── PIN ────────────────────────────────────────────────────────
            _fieldLabel('4-Digit PIN'),
            const SizedBox(height: 6),
            TextField(
              controller: _pinCtrl,
              obscureText: !_pinVisible,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: _kInk,
                fontSize: 22,
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                hintText: '• • • •',
                hintStyle: TextStyle(
                  color: _kInkSoft,
                  letterSpacing: 6,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.lock_rounded,
                  color: _kInkMid,
                  size: 18,
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _pinVisible = !_pinVisible),
                  child: Icon(
                    _pinVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: _kInkMid,
                    size: 18,
                  ),
                ),
                counterText: '',
                filled: true,
                fillColor: _kBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _kBlue.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // ── Error ──────────────────────────────────────────────────────
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: _kRed,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _error,
                    style: const TextStyle(color: _kRed, fontSize: 12),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ── Save button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  disabledBackgroundColor: _kInkSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Add Cashier',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _kBlue.withOpacity(0.08) : _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _kBlue : _kInkSoft,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? _kBlue : _kInkMid, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? _kBlue : _kInkMid,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        color: _kInkMid,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  InputDecoration _inputDecor({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kInkSoft, fontSize: 14),
        prefixIcon: Icon(icon, color: _kInkMid, size: 18),
        filled: true,
        fillColor: _kBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kBlue.withOpacity(0.5), width: 1.5),
        ),
      );
}

// ─────────────────────────────────────────────
//  SELLER DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _SellerDetailSheet extends StatefulWidget {
  final Seller seller;
  final Color avatarColor;

  const _SellerDetailSheet({required this.seller, required this.avatarColor});

  @override
  State<_SellerDetailSheet> createState() => _SellerDetailSheetState();
}

class _SellerDetailSheetState extends State<_SellerDetailSheet> {
  final _db = DatabaseHelper.instance;
  final _fmt = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  bool _loading = true;
  _DetailPeriod _period = _DetailPeriod.today;
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTimeRange get _range {
    final now = DateTime.now();
    switch (_period) {
      case _DetailPeriod.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case _DetailPeriod.week:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );
      case _DetailPeriod.month:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = _range;
      final summary = await _db.getSellerSummary(
        widget.seller.id!,
        from: r.start,
        to: r.end,
      );
      final sales = await _db.getSalesBySeller(
        widget.seller.id!,
        from: r.start,
        to: r.end,
      );
      setState(() {
        _summary = summary;
        _sales = sales;
        _loading = false;
      });
    } catch (e) {
      debugPrint('SellerDetail _load error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenue = (_summary['total_revenue'] ?? 0.0) as double;
    final orders = (_summary['transaction_count'] ?? 0) as int;
    final items = (_summary['total_items_sold'] ?? 0) as int;
    final color = widget.avatarColor;
    final initials = widget.seller.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: const BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kInkSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Seller header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.35),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.seller.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: _kInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.seller.isOwner ? 'Owner' : 'Cashier',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Period tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: _DetailPeriod.values.map((p) {
                  const labels = {
                    _DetailPeriod.today: 'Today',
                    _DetailPeriod.week: 'This Week',
                    _DetailPeriod.month: 'This Month',
                  };
                  final active = p == _period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _period = p);
                        _load();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: active ? _kBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            labels[p]!,
                            style: TextStyle(
                              color: active ? Colors.white : _kInkMid,
                              fontSize: 11,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: _kBlue)),
            )
          else ...[
            // KPI row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _kpi(_fmt.format(revenue), 'Revenue', _kBlue),
                  const SizedBox(width: 10),
                  _kpi('$orders', 'Sales', _kGreen),
                  const SizedBox(width: 10),
                  _kpi('$items', 'Items Sold', _kOrange),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _kBorder),

            // Sales list
            Expanded(
              child: _sales.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: _kInkSoft,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No sales in this period',
                            style: TextStyle(color: _kInkMid, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _sales.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: _kBorder),
                      itemBuilder: (_, i) {
                        final sale = _sales[i];
                        final total = sale['total'] as double;
                        final dt = DateTime.parse(sale['sold_at'] as String);
                        final h = dt.hour > 12
                            ? dt.hour - 12
                            : (dt.hour == 0 ? 12 : dt.hour);
                        final m = dt.minute.toString().padLeft(2, '0');
                        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
                        final time = '$h:$m $ampm';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _kBlue.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.receipt_rounded,
                              color: _kBlue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            sale['receipt_no'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _kInk,
                            ),
                          ),
                          subtitle: Text(
                            '${sale['item_count']} item${(sale['item_count'] as int) == 1 ? '' : 's'}  ·  $time',
                            style: const TextStyle(
                              color: _kInkMid,
                              fontSize: 11,
                            ),
                          ),
                          trailing: Text(
                            _fmt.format(total),
                            style: const TextStyle(
                              color: _kGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kpi(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _kInkMid, fontSize: 10)),
        ],
      ),
    ),
  );
}

enum _DetailPeriod { today, week, month }
