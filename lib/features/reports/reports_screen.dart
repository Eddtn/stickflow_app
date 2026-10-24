

import 'package:flutter/material.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/core/constant.dart';

enum _Period { today, week, month, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;

  _Period _period = _Period.week;
  DateTime? _customFrom;
  DateTime? _customTo;
  bool _loading = true;

  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _dailyRevenue = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _categoryBreakdown = [];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  DateTimeRange get _range {
    final now = DateTime.now();
    switch (_period) {
      case _Period.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case _Period.week:
        return DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6)),
          end: now,
        );
      case _Period.month:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case _Period.custom:
        return DateTimeRange(
          start: _customFrom ?? now.subtract(const Duration(days: 6)),
          end: _customTo ?? now,
        );
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _animCtrl.reset();

    final r = _range;
    final summary = await _db.getSalesSummary(from: r.start, to: r.end);
    final sales = await _db.getSalesByDateRange(r.start, r.end);
    final daily = await _buildDailyRevenue(sales, r);
    final topProds = await _fetchTopProducts(sales);
    final cats = await _fetchCategoryBreakdown(sales);

    setState(() {
      _summary = summary;
      _dailyRevenue = daily;
      _topProducts = topProds;
      _categoryBreakdown = cats;
      _loading = false;
    });
    _animCtrl.forward();
  }

  // ── Safe helper: any num → double ─────────────────────────────────────────
  double _toDouble(dynamic v) => ((v ?? 0) as num).toDouble();

  Future<List<Map<String, dynamic>>> _buildDailyRevenue(
    List<Map<String, dynamic>> sales,
    DateTimeRange range,
  ) async {
    final Map<String, double> dayMap = {};
    var cursor = range.start;
    while (!cursor.isAfter(range.end)) {
      dayMap[_dayKey(cursor)] = 0;
      cursor = cursor.add(const Duration(days: 1));
    }
    for (final sale in sales) {
      final key = _dayKey(DateTime.parse(sale['sold_at'] as String));
      dayMap[key] = (dayMap[key] ?? 0) + _toDouble(sale['total']);
    }
    return dayMap.entries
        .map((e) => {'day': e.key, 'revenue': e.value})
        .toList();
  }

  Future<List<Map<String, dynamic>>> _fetchTopProducts(
    List<Map<String, dynamic>> sales,
  ) async {
    final Map<String, Map<String, dynamic>> productMap = {};
    for (final sale in sales) {
      final items = await _db.getSaleItems(sale['id'] as int);
      for (final item in items) {
        final barcode = item['barcode'] as String;
        if (!productMap.containsKey(barcode)) {
          productMap[barcode] = {
            'name': item['name'],
            'icon': item['icon'],
            'qty': 0,
            'revenue': 0.0,
          };
        }
        productMap[barcode]!['qty'] += item['quantity'] as int;
        productMap[barcode]!['revenue'] += _toDouble(item['subtotal']);
      }
    }
    final list = productMap.values.toList()
      ..sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
      );
    return list.take(5).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchCategoryBreakdown(
    List<Map<String, dynamic>> sales,
  ) async {
    final Map<String, double> catMap = {};
    for (final sale in sales) {
      final items = await _db.getSaleItems(sale['id'] as int);
      for (final item in items) {
        final product = await _db.getProductByBarcode(
          item['barcode'] as String,
        );
        final category = (product?['category'] as String?) ?? 'Other';
        catMap[category] =
            (catMap[category] ?? 0) + _toDouble(item['subtotal']);
      }
    }
    final total = catMap.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return [];
    final list =
        catMap.entries
            .map(
              (e) => {
                'category': e.key,
                'revenue': e.value,
                'pct': (e.value / total * 100).roundToDouble(),
              },
            )
            .toList()
          ..sort(
            (a, b) =>
                (b['revenue'] as double).compareTo(a['revenue'] as double),
          );
    return list;
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _customFrom ?? DateTime.now().subtract(const Duration(days: 6)),
        end: _customTo ?? DateTime.now(),
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppDarkColors.accent,
            onPrimary: AppDarkColors.bg,
            surface: AppDarkColors.card,
            onSurface: AppDarkColors.text,
          ),
          dialogBackgroundColor: AppDarkColors.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customFrom = picked.start;
        _customTo = picked.end;
        _period = _Period.custom;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppDarkColors.bg),
      child: Scaffold(
        backgroundColor: AppDarkColors.bg,
        appBar: AppBar(
          backgroundColor: AppDarkColors.bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppDarkColors.textDim,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Reports',
            style: TextStyle(
              color: AppDarkColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildPeriodBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppDarkColors.accent),
                    )
                  : FadeTransition(
                      opacity: _fadeAnim,
                      child: RefreshIndicator(
                        onRefresh: _load,
                        color: AppDarkColors.accent,
                        backgroundColor: AppDarkColors.card,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          children: [
                            _buildKpiRow(),
                            const SizedBox(height: 16),
                            _buildRevenueChart(),
                            const SizedBox(height: 16),
                            _buildTopProducts(),
                            const SizedBox(height: 16),
                            _buildCategoryBreakdown(),
                            const SizedBox(height: 16),
                            _buildBestWorstDay(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppDarkColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _periodBtn('Today', _Period.today),
                  _periodBtn('Week', _Period.week),
                  _periodBtn('Month', _Period.month),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _pickCustomRange,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _period == _Period.custom
                    ? AppDarkColors.accent.withOpacity(0.15)
                    : AppDarkColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _period == _Period.custom
                      ? AppDarkColors.accent.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 16,
                    color: _period == _Period.custom ? AppDarkColors.accent : AppDarkColors.textDim,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _period == _Period.custom && _customFrom != null
                        ? '${_customFrom!.day}/${_customFrom!.month} – ${_customTo!.day}/${_customTo!.month}'
                        : 'Custom',
                    style: TextStyle(
                      color: _period == _Period.custom ? AppDarkColors.accent : AppDarkColors.textDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodBtn(String label, _Period p) {
    final active = _period == p;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _period = p);
          _load();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? AppDarkColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppDarkColors.bg : AppDarkColors.textDim,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow() {
    // ✅ Safe cast — works whether SQLite returns int or double
    final revenue = _toDouble(_summary['total_revenue']);
    final orders = (_summary['transaction_count'] ?? 0) as int;
    final avg = _toDouble(_summary['avg_order_value']);
    final items = (_summary['total_items_sold'] ?? 0) as int;

    return Column(
      children: [
        Row(
          children: [
            _kpiCard(
              'Total Revenue',
              '₦${_fmt(revenue.toInt())}',
              AppDarkColors.accent,
              Icons.payments_rounded,
            ),
            const SizedBox(width: 10),
            _kpiCard(
              'Total Orders',
              '$orders',
              AppDarkColors.lightBlue,
              Icons.receipt_long_rounded,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _kpiCard(
              'Avg Order Value',
              '₦${_fmt(avg.toInt())}',
              AppDarkColors.warning,
              Icons.bar_chart_rounded,
            ),
            const SizedBox(width: 10),
            _kpiCard(
              'Items Sold',
              '$items',
              AppDarkColors.pink,
              Icons.shopping_bag_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDarkColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppDarkColors.textDim, fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _buildRevenueChart() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppDarkColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(
                color: AppDarkColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppDarkColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _periodLabel,
                style: const TextStyle(color: AppDarkColors.accent, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _dailyRevenue.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No sales in this period',
                    style: TextStyle(color: AppDarkColors.textDim),
                  ),
                ),
              )
            : SizedBox(
                height: 160,
                child: _RevenueBarChart(data: _dailyRevenue),
              ),
      ],
    ),
  );

  String get _periodLabel {
    switch (_period) {
      case _Period.today:
        return 'Today';
      case _Period.week:
        return 'Last 7 days';
      case _Period.month:
        return 'This month';
      case _Period.custom:
        return 'Custom range';
    }
  }

  Widget _buildTopProducts() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppDarkColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Selling Products',
          style: TextStyle(
            color: AppDarkColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 14),
        _topProducts.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No sales data',
                    style: TextStyle(color: AppDarkColors.textDim),
                  ),
                ),
              )
            : Column(
                children: List.generate(_topProducts.length, (i) {
                  final p = _topProducts[i];
                  final maxRev = _toDouble(_topProducts.first['revenue']);
                  final rev = _toDouble(p['revenue']);
                  final pct = maxRev > 0 ? rev / maxRev : 0.0;
                  final colors = [
                    AppDarkColors.accent,
                    AppDarkColors.lightBlue,
                    AppDarkColors.warning,
                    AppDarkColors.pink,
                    AppDarkColors.textDim,
                  ];
                  final color = colors[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          p['icon'] as String,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p['name'] as String,
                                      style: const TextStyle(
                                        color: AppDarkColors.text,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '₦${_fmt(rev.toInt())}',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 4,
                                  backgroundColor: Colors.white10,
                                  valueColor: AlwaysStoppedAnimation(color),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${p['qty']} unit${(p['qty'] as int) == 1 ? '' : 's'} sold',
                                style: const TextStyle(
                                  color: AppDarkColors.textDim,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
      ],
    ),
  );

  Widget _buildCategoryBreakdown() {
    if (_categoryBreakdown.isEmpty) return const SizedBox.shrink();
    final colors = [
      AppDarkColors.accent,
      AppDarkColors.lightBlue,
      AppDarkColors.warning,
      AppDarkColors.pink,
      AppDarkColors.accentDim,
      AppDarkColors.lightPurple,
      AppDarkColors.skyBlue,
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppDarkColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales by Category',
            style: TextStyle(
              color: AppDarkColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: _DonutChart(data: _categoryBreakdown, colors: colors),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: List.generate(_categoryBreakdown.length, (i) {
                    final c = _categoryBreakdown[i];
                    final color = colors[i % colors.length];
                    // ✅ Safe cast for pct
                    final pct = _toDouble(c['pct']);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c['category'] as String,
                              style: const TextStyle(
                                color: AppDarkColors.text,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestWorstDay() {
    if (_dailyRevenue.isEmpty) return const SizedBox.shrink();
    final withSales = _dailyRevenue
        .where((d) => _toDouble(d['revenue']) > 0)
        .toList();
    if (withSales.isEmpty) return const SizedBox.shrink();

    withSales.sort(
      (a, b) => _toDouble(b['revenue']).compareTo(_toDouble(a['revenue'])),
    );
    final best = withSales.first;
    final worst = withSales.last;

    return Row(
      children: [
        Expanded(
          child: _dayCard(
            label: '🏆  Best Day',
            day: best['day'] as String,
            revenue: _toDouble(best['revenue']),
            color: AppDarkColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dayCard(
            label: '📉  Lowest Day',
            day: worst['day'] as String,
            revenue: _toDouble(worst['revenue']),
            color: AppDarkColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _dayCard({
    required String label,
    required String day,
    required double revenue,
    required Color color,
  }) {
    final dt = DateTime.parse(day);
    const months = [
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDarkColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppDarkColors.textDim, fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            '${dt.day} ${months[dt.month - 1]}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₦${_fmt(revenue.toInt())}',
            style: const TextStyle(
              color: AppDarkColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

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
}

// ─────────────────────────────────────────────
//  REVENUE BAR CHART
// ─────────────────────────────────────────────
class _RevenueBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _RevenueBarChart({required this.data});

  double _d(dynamic v) => ((v ?? 0) as num).toDouble();

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(0, (m, d) {
      final v = _d(d['revenue']);
      return v > m ? v : m;
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        final rev = _d(d['revenue']);
        final frac = maxVal > 0 ? rev / maxVal : 0.0;
        final dt = DateTime.parse(d['day'] as String);
        final label = '${dt.day}/${dt.month}';
        final hasData = rev > 0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasData)
                  Text(
                    '₦${_shortFmt(rev.toInt())}',
                    style: const TextStyle(
                      color: AppDarkColors.accent,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: (frac * 110).clamp(4.0, 110.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: hasData
                          ? [AppDarkColors.accent, AppDarkColors.accentDim]
                          : [Colors.white10, Colors.white10],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: const TextStyle(color: AppDarkColors.textDim, fontSize: 8),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shortFmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return '$v';
  }
}

// ─────────────────────────────────────────────
//  DONUT CHART
// ─────────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<Color> colors;
  const _DonutChart({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DonutPainter(data: data, colors: colors),
  );
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final List<Color> colors;
  _DonutPainter({required this.data, required this.colors});

  double _d(dynamic v) => ((v ?? 0) as num).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (s, d) => s + _d(d['pct']));
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -1.5708;

    for (int i = 0; i < data.length; i++) {
      final pct = _d(data[i]['pct']) / total;
      final sweepAngle = pct * 6.2832;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle - 0.04,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => true;
}
