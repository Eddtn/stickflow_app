// lib/screens/sales_history_screen.dart
//
// Complete Sales History screen.
// Shows all past transactions with filters (Today / This Week / This Month / All),
// summary stats bar, searchable transaction list, and a detail sheet per sale.

import 'package:flutter/material.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/services/seller_session.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kAccentDim = Color(0xFF00B87A);
const _kWarning = Color(0xFFFFB547);
const _kDanger = Color(0xFFFF5370);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

enum _Filter { today, week, month, all }

// ─────────────────────────────────────────────
//  SALES HISTORY SCREEN
// ─────────────────────────────────────────────
class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _sales = [];
  Map<String, dynamic> _summary = {};
  bool _loading = true;
  _Filter _filter = _Filter.today;
  String _search = '';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  DateTimeRange _range(_Filter f) {
    final now = DateTime.now();
    switch (f) {
      case _Filter.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case _Filter.week:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );
      case _Filter.month:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case _Filter.all:
        return DateTimeRange(start: DateTime(2000), end: now);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _fadeCtrl.reset();

    final r = _range(_filter);
    var sales = await _db.getSalesByDateRange(r.start, r.end);
    final summary = await _db.getSalesSummary(from: r.start, to: r.end);

    // Client-side search filter
    final filtered = _search.isEmpty
        ? sales
        : sales
              .where(
                (s) => (s['receipt_no'] as String).toLowerCase().contains(
                  _search.toLowerCase(),
                ),
              )
              .toList();

    final session = SellerSession.instance;

    if (session.isOwner) {
      // Owner sees everything
      sales = await _db.getSalesByDateRange(r.start, r.end);
    } else {
      // Cashier sees only their own
      sales = await _db.getSalesBySeller(
        session.sellerId!,
        from: r.start,
        to: r.end,
      );
    }

    setState(() {
      _sales = filtered;
      _summary = summary;
      _loading = false;
    });
    _fadeCtrl.forward();
  }

  void _setFilter(_Filter f) {
    setState(() => _filter = f);
    _load();
  }

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
            'Sales History',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            _buildSummaryRow(),
            _buildSearchBar(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ── Filter tabs ─────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    const labels = {
      _Filter.today: 'Today',
      _Filter.week: 'This Week',
      _Filter.month: 'This Month',
      _Filter.all: 'All Time',
    };
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _Filter.values.map((f) {
          final selected = f == _filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? _kAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    labels[f]!,
                    style: TextStyle(
                      color: selected ? _kBg : _kTextDim,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Summary row ──────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    final revenue = (_summary['total_revenue'] ?? 0.0) as double;
    final count = (_summary['transaction_count'] ?? 0) as int;
    final avg = (_summary['avg_order_value'] ?? 0.0) as double;
    final items = (_summary['total_items_sold'] ?? 0) as int;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _summaryCard(
            'Revenue',
            '₦${_fmt(revenue.toInt())}',
            _kAccent,
            Icons.payments_rounded,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            'Sales',
            '$count',
            _kWarning,
            Icons.receipt_long_rounded,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            'Avg Order',
            '₦${_fmt(avg.toInt())}',
            const Color(0xFF7C9FFF),
            Icons.bar_chart_rounded,
          ),
          const SizedBox(width: 10),
          _summaryCard(
            'Items',
            '$items',
            const Color(0xFFFF85A2),
            Icons.shopping_bag_rounded,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
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
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: const TextStyle(color: _kTextDim, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  // ── Search ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TextField(
        onChanged: (v) {
          _search = v.trim();
          _load();
        },
        style: const TextStyle(color: _kText, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search by receipt number…',
          hintStyle: const TextStyle(color: _kTextDim, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _kTextDim,
            size: 18,
          ),
          filled: true,
          fillColor: _kCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _kAccent.withOpacity(0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _kAccent));
    }
    if (_sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _kCard,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: _kTextDim,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No sales found',
              style: TextStyle(
                color: _kText,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Complete a sale to see it here',
              style: TextStyle(color: _kTextDim, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _sales.length,
        itemBuilder: (ctx, i) => _buildSaleCard(_sales[i]),
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale) {
    final total = (sale['total'] as double);
    final itemCount = sale['item_count'] as int;
    final soldAt = DateTime.parse(sale['sold_at'] as String);

    return GestureDetector(
      onTap: () => _openDetail(sale),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_rounded,
                color: _kAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale['receipt_no'] as String,
                    style: const TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'}  ·  ${_timeAgo(soldAt)}',
                    style: const TextStyle(color: _kTextDim, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${_fmt(total.toInt())}',
                  style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kAccentDim.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: _kAccentDim,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: _kTextDim, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Detail sheet ─────────────────────────────────────────────────────────
  void _openDetail(Map<String, dynamic> sale) async {
    final items = await _db.getSaleItems(sale['id'] as int);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaleDetailSheet(sale: sale, items: items),
    ).then((_) => _load()); // refresh after possible delete
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _fmt(int price) {
    if (price >= 1000) {
      final s = price.toString();
      final result = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result.write(',');
        result.write(s[i]);
        count++;
      }
      return result.toString().split('').reversed.join();
    }
    return price.toString();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

// ─────────────────────────────────────────────
//  SALE DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _SaleDetailSheet extends StatelessWidget {
  final Map<String, dynamic> sale;
  final List<Map<String, dynamic>> items;

  const _SaleDetailSheet({required this.sale, required this.items});

  String _fmt(int price) {
    if (price >= 1000) {
      final s = price.toString();
      final result = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result.write(',');
        result.write(s[i]);
        count++;
      }
      return result.toString().split('').reversed.join();
    }
    return price.toString();
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  ·  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = sale['subtotal'] as double;
    final vat = sale['vat'] as double;
    final total = sale['total'] as double;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      margin: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  color: _kAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale['receipt_no'] as String,
                      style: const TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatDate(sale['sold_at'] as String),
                      style: const TextStyle(color: _kTextDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Delete button
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: _kCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: const Text(
                        'Delete Sale',
                        style: TextStyle(color: _kText),
                      ),
                      content: const Text(
                        'Remove this transaction from history?',
                        style: TextStyle(color: _kTextDim),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: _kTextDim),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: _kDanger),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DatabaseHelper.instance.deleteSale(sale['id'] as int);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: _kDanger,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // Items
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (ctx, i) {
                final item = items[i];
                final sub = item['subtotal'] as double;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        item['icon'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                color: _kText,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${item['brand']}  ·  ₦${_fmt(item['unit_price'] as int)} × ${item['quantity']}',
                              style: const TextStyle(
                                color: _kTextDim,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₦${_fmt(sub.toInt())}',
                        style: const TextStyle(
                          color: _kText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // Totals
          _row('Subtotal', '₦${_fmt(subtotal.toInt())}'),
          const SizedBox(height: 6),
          _row('VAT (7.5%)', '₦${_fmt(vat.toInt())}'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 30),

            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kAccent.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL PAID',
                  style: TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '₦${_fmt(total.toInt())}',
                  style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: _kTextDim, fontSize: 13)),
      Text(value, style: const TextStyle(color: _kText, fontSize: 13)),
    ],
  );
}
