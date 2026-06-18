// lib/screens/low_stock_screen.dart
//
// Low Stock Alerts screen.
// • Shows all products that are at or below their alert threshold
// • Lets the user adjust the threshold per product (slider)
// • One-tap "Notify Me Now" button to send an immediate push notification
// • Live badge count shown on the POS header icon

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/services/notification/notification_service.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kWarning = Color(0xFFFFB547);
const _kDanger = Color(0xFFFF5370);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _lowStock = [];
  List<Map<String, dynamic>> _allProducts = [];
  bool _loading = true;
  bool _showAll = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _load();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final low = await _db.getLowStockProducts();
    final all = await _db.getAllProducts();
    setState(() {
      _lowStock = low;
      _allProducts = all;
      _loading = false;
    });
  }

  Future<void> _updateThreshold(int productId, int threshold) async {
    await _db.setAlertThreshold(productId, threshold);
    await _load();
  }

  Future<void> _notifyNow() async {
    HapticFeedback.mediumImpact();
    await NotificationService.instance.sendLowStockNow();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Low stock notification sent'),
          ],
        ),
        backgroundColor: _kWarning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _showAll ? _allProducts : _lowStock;

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
            'Stock Alerts',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            if (_lowStock.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: _notifyNow,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) =>
                        Transform.scale(scale: _pulseAnim.value, child: child),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _kWarning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kWarning.withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.notifications_active_rounded,
                            color: _kWarning,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Notify',
                            style: TextStyle(
                              color: _kWarning,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _kAccent))
            : Column(
                children: [
                  _buildSummaryBanner(),
                  _buildToggle(),
                  Expanded(
                    child: displayList.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: displayList.length,
                            itemBuilder: (ctx, i) =>
                                _buildProductCard(displayList[i]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Summary banner ────────────────────────────────────────────────────────
  Widget _buildSummaryBanner() {
    final critical = _lowStock.where((p) => (p['stock'] as int) == 0).length;
    final warning = _lowStock.where((p) => (p['stock'] as int) > 0).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _lowStock.isEmpty
              ? [_kAccent.withOpacity(0.1), _kAccent.withOpacity(0.05)]
              : [_kWarning.withOpacity(0.12), _kDanger.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _lowStock.isEmpty
              ? _kAccent.withOpacity(0.2)
              : _kWarning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _lowStock.isEmpty
                  ? _kAccent.withOpacity(0.15)
                  : _kWarning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _lowStock.isEmpty
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: _lowStock.isEmpty ? _kAccent : _kWarning,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _lowStock.isEmpty
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All stock levels healthy',
                        style: TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'No products below their alert threshold',
                        style: TextStyle(color: _kTextDim, fontSize: 12),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_lowStock.length} product${_lowStock.length == 1 ? '' : 's'} need restocking',
                        style: const TextStyle(
                          color: _kWarning,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (critical > 0) ...[
                            _pill('$critical out of stock', _kDanger),
                            const SizedBox(width: 6),
                          ],
                          if (warning > 0) _pill('$warning low', _kWarning),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );

  // ── Toggle: Low stock only / All products ─────────────────────────────────
  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAll = false),
              child: _toggleBtn(
                label: 'Low Stock (${_lowStock.length})',
                active: !_showAll,
                color: _kWarning,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAll = true),
              child: _toggleBtn(
                label: 'All Products (${_allProducts.length})',
                active: _showAll,
                color: _kAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn({
    required String label,
    required bool active,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? color.withOpacity(0.4) : Colors.white10,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : _kTextDim,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Product card ──────────────────────────────────────────────────────────
  Widget _buildProductCard(Map<String, dynamic> p) {
    final stock = p['stock'] as int;
    final threshold = p['alert_threshold'] as int? ?? 10;
    final isOut = stock == 0;
    final isLow = stock > 0 && stock <= threshold;

    Color statusColor = _kAccent;
    String statusLabel = 'OK';
    if (isOut) {
      statusColor = _kDanger;
      statusLabel = 'OUT';
    } else if (isLow) {
      statusColor = _kWarning;
      statusLabel = 'LOW';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOut
              ? _kDanger.withOpacity(0.25)
              : isLow
              ? _kWarning.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Theme(
        data: ThemeData.dark(),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    p['icon'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            p['name'] as String,
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                '${p['brand']}  ·  ${p['category']}',
                style: const TextStyle(color: _kTextDim, fontSize: 11),
              ),
              const SizedBox(height: 6),
              _stockBar(stock, threshold),
              const SizedBox(height: 4),
              Text(
                isOut
                    ? 'Out of stock!'
                    : '$stock remaining  ·  Alert at ≤ $threshold',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.tune_rounded, color: _kTextDim, size: 18),
          // ── Expanded: threshold slider ───────────────────────────────
          children: [
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alert Threshold',
                  style: TextStyle(color: _kTextDim, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kWarning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '≤ $threshold units',
                    style: const TextStyle(
                      color: _kWarning,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _kWarning,
                inactiveTrackColor: _kWarning.withOpacity(0.15),
                thumbColor: _kWarning,
                overlayColor: _kWarning.withOpacity(0.15),
                trackHeight: 4,
              ),
              child: Slider(
                value: threshold.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                onChanged: (v) async {
                  await _updateThreshold(p['id'] as int, v.toInt());
                },
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1', style: TextStyle(color: _kTextDim, fontSize: 11)),
                Text('100', style: TextStyle(color: _kTextDim, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Stock progress bar ────────────────────────────────────────────────────
  Widget _stockBar(int stock, int threshold) {
    // Show relative to threshold×2 so bar has context
    final max = (threshold * 2).clamp(20, 500);
    final frac = (stock / max).clamp(0.0, 1.0);
    Color color = _kAccent;
    if (stock == 0)
      color = _kDanger;
    else if (stock <= threshold)
      color = _kWarning;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: frac,
        minHeight: 5,
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: _kAccent,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'All good!',
            style: TextStyle(
              color: _kText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No products are below\ntheir alert threshold',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kTextDim, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
