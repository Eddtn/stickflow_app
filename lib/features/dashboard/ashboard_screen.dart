







import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/core/constant.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/auth/lock_screen.dart';
import 'package:stockflow/features/backUp_screen/backup_screen.dart';
import 'package:stockflow/features/dashboard/sellerScreen.dart';
import 'package:stockflow/features/posscreen/posscreen.dart';
import 'package:stockflow/features/products/products_screen.dart';
import 'package:stockflow/features/reports/reports_screen.dart';
import 'package:stockflow/features/sales_history/sales_history.dart';
import 'package:stockflow/features/setting_screen.dart';
import 'package:stockflow/features/stock/low_stock_screen.dart';
import 'package:stockflow/features/stock/stockInScreen.dart';
import 'package:stockflow/services/seller_session.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── state ─────────────────────────────────────────────────────────────────
  bool _loading = true;
  String _error = '';

  int _totalProducts = 0;
  int _lowStockCount = 0;
  int _todayOrders = 0;
  double _todayRevenue = 0;
  double _weekRevenue = 0;
  int _inventoryValue = 0;

  List<Map<String, dynamic>> _lowStockItems = [];
  List<_TopItem> _topItems = [];
  List<double> _weeklyBars = List.filled(7, 0);

  final _fmt = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── load — simple sequential, each step isolated ──────────────────────────
  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final db = DatabaseHelper.instance;

      // 1. Products
      final products = await db.getAllProducts();
      final lowStockRows = await db.getLowStockProducts();

      // 2. Today's sales
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todaySales = await db.getSalesByDateRange(today, now);

      // 3. Weekly bars (last 7 days)
      final bars = <double>[];
      double weekRev = 0;
      for (int i = 6; i >= 0; i--) {
        final d = today.subtract(Duration(days: i));
        final d2 = d.add(const Duration(days: 1));
        final rows = await db.getSalesByDateRange(d, d2);
        final rev = rows.fold<double>(0, (s, r) => s + (r['total'] as double));
        bars.add(rev);
        weekRev += rev;
      }

      // 4. Top products from today's sales
      final topMap = <String, _TopItem>{};
      for (final sale in todaySales) {
        final items = await db.getSaleItems(sale['id'] as int);
        for (final item in items) {
          final b = item['barcode'] as String;
          topMap.putIfAbsent(
            b,
            () => _TopItem(
              icon: item['icon'] as String? ?? '📦',
              name: item['name'] as String,
              qty: 0,
              revenue: 0,
            ),
          );
          topMap[b]!.qty += item['quantity'] as int;
          topMap[b]!.revenue += item['subtotal'] as double;
        }
      }
      final topList = topMap.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      // 5. Inventory value
      final invVal = products.fold<int>(
        0,
        (s, p) => s + (p['price'] as int) * (p['stock'] as int),
      );

      if (!mounted) return;
      setState(() {
        _totalProducts = products.length;
        _lowStockCount = lowStockRows.length;
        _lowStockItems = lowStockRows.take(3).toList();
        _todayOrders = todaySales.length;
        _todayRevenue = todaySales.fold(
          0,
          (s, r) => s + (r['total'] as double),
        );
        _weekRevenue = weekRev;
        _weeklyBars = bars;
        _inventoryValue = invVal;
        _topItems = topList.take(4).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ── greeting ──────────────────────────────────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  // ── navigate and refresh on return ───────────────────────────────────────
  void _go(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _load());
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _error.isNotEmpty
              ? _buildError()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildRevenueCard()),
                      SliverToBoxAdapter(child: _buildKpiRow()),
                      SliverToBoxAdapter(child: _buildWeeklyChart()),
                      SliverToBoxAdapter(child: _buildTopProducts()),
                      SliverToBoxAdapter(child: _buildLowStock()),
                      SliverToBoxAdapter(child: _buildQuickActions()),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ── error ─────────────────────────────────────────────────────────────────
  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Failed to load dashboard',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            _error,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  // ── header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // notification bell
          Stack(
            children: [
              _iconBtn(
                Icons.notifications_outlined,
                () => _go(const LowStockScreen()),
              ),
              if (_lowStockCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _lowStockCount > 9 ? '9+' : '$_lowStockCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _go(const SettingsScreen()),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'SF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    ),
  );

  // ── revenue hero card ─────────────────────────────────────────────────────
  Widget _buildRevenueCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0044DD), Color(0xFF0099FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Revenue",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_todayOrders order${_todayOrders == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _fmt.format(_todayRevenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white54,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                'This week: ${_fmt.format(_weekRevenue)}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4 KPI cards ───────────────────────────────────────────────────────────
  Widget _buildKpiRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _kpiCard(
            'Products',
            '$_totalProducts',
            Icons.inventory_2_rounded,
            AppColors.primary,
            AppColors.primarySoft,
          ),
          _kpiCard(
            'Low Stock',
            '$_lowStockCount',
            Icons.warning_amber_rounded,
            AppColors.warning,
            AppColors.warningSoft,
          ),
          _kpiCard(
            "Today's Orders",
            '$_todayOrders',
            Icons.shopping_cart_rounded,
            AppColors.success,
            AppColors.successSoft,
          ),
          _kpiCard(
            'Inventory Value',
            _inventoryValue >= 1000000
                ? '₦${(_inventoryValue / 1000000).toStringAsFixed(1)}M'
                : '₦${(_inventoryValue / 1000).toStringAsFixed(0)}k',
            Icons.account_balance_wallet_rounded,
            AppColors.accentPurple,
            AppColors.accentPurpleSoft,
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── weekly bar chart ──────────────────────────────────────────────────────
  Widget _buildWeeklyChart() {
    final maxVal = _weeklyBars.fold<double>(0, (m, v) => v > m ? v : m);

    return _section(
      title: 'Sales Trend — Last 7 Days',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final val = _weeklyBars[i];
            final frac = maxVal > 0 ? val / maxVal : 0.0;
            final day = DateTime.now().subtract(Duration(days: 6 - i));
            final label = DateFormat('E').format(day).substring(0, 2);
            final isToday = i == 6;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (val > 0)
                      Text(
                        val >= 1000
                            ? '${(val / 1000).toStringAsFixed(0)}k'
                            : val.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      height: (frac * 90).clamp(4.0, 90.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isToday
                              ? [AppColors.primary, const Color(0xFF3399FF)]
                              : [AppColors.primarySoft, AppColors.primarySoft],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── top products ──────────────────────────────────────────────────────────
  Widget _buildTopProducts() {
    if (_topItems.isEmpty) {
      return _section(
        title: "Today's Top Products",
        icon: Icons.star_rounded,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'No sales today yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final maxRev = _topItems.first.revenue;
    const colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.accentPurple,
    ];

    return _section(
      title: "Today's Top Products",
      icon: Icons.star_rounded,
      child: Column(
        children: List.generate(_topItems.length, (i) {
          final item = _topItems[i];
          final pct = maxRev > 0 ? item.revenue / maxRev : 0.0;
          final color = colors[i % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _fmt.format(item.revenue),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.qty} unit${item.qty == 1 ? '' : 's'} sold',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
    );
  }

  // ── low stock ─────────────────────────────────────────────────────────────
  Widget _buildLowStock() {
    return _section(
      title: 'Low Stock Alerts',
      icon: Icons.warning_amber_rounded,
      iconColor: _lowStockCount > 0 ? AppColors.warning : AppColors.success,
      trailing: _lowStockCount > 0
          ? GestureDetector(
              onTap: () => _go(const LowStockScreen()),
              child: Text(
                'View all $_lowStockCount →',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      child: _lowStockItems.isEmpty
          ? const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'All stock levels healthy!',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Column(
              children: _lowStockItems.map((p) {
                final stock = p['stock'] as int;
                final threshold = (p['alert_threshold'] as int?) ?? 10;
                final isOut = stock == 0;
                final color = isOut ? AppColors.danger : AppColors.warning;
                final label = isOut ? 'Out' : 'Low';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        p['icon'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${p['brand']}  ·  $stock left',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ── quick actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _Action(
        'Scan & Sell',
        Icons.qr_code_scanner_rounded,
        AppColors.primary,
        () => _go(const PosScreen()),
      ),
      _Action(
        'Stock In',
        Icons.arrow_downward_rounded,
        AppColors.success,
        () => _go(const StockInScreen()),
      ), // NEW
      _Action(
        'Products',
        Icons.inventory_2_rounded,
        AppColors.accentTeal,
        () => _go(const ProductsScreen()),
      ),
      _Action(
        'Sales',
        Icons.receipt_long_rounded,
        AppColors.accentPurple,
        () => _go(const SalesHistoryScreen()),
      ),
      _Action(
        'Sellers',
        Icons.group_rounded,
        AppColors.warning,
        () => _go(const SellersScreen()),
      ),

      if (SellerSession.instance.canViewReports)
        _Action(
          'Reports',
          Icons.bar_chart_rounded,
          AppColors.danger,
          () => _go(const ReportsScreen()),
        ),
      _Action(
        'Backup',
        Icons.backup_rounded,
        AppColors.accentTeal,
        () => _go(const BackupScreen()),
      ),

      if (SellerSession.instance.canAccessSettings)
        _Action(
          'Settings',
          Icons.settings_rounded,
          AppColors.textSecondary,
          () => _go(const SettingsScreen()),
        ),

      _Action(
        'Cashiers',
        Icons.people_rounded,
        AppColors.accentTeal,
        () => _go(const SellersScreen()),
      ),

      _Action(
        'Stock In',
        Icons.arrow_downward_rounded,
        AppColors.accentTeal,
        () => _go(const StockInScreen()),
      ),
    ];

    return _section(
      title: 'Quick Actions',
      icon: Icons.flash_on_rounded,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
        children: actions
            .map(
              (a) => GestureDetector(
                onTap: a.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: a.color.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, color: a.color, size: 22),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        a.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: a.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── section card helper ───────────────────────────────────────────────────
  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
    Color iconColor = AppColors.textPrimary,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 17),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── tiny data classes ─────────────────────────────────────────────────────────
class _TopItem {
  final String icon, name;
  int qty;
  double revenue;
  _TopItem({
    required this.icon,
    required this.name,
    required this.qty,
    required this.revenue,
  });
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _Action(this.label, this.icon, this.color, this.onTap);
}
