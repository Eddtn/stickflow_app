// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final currency = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text(
//           'StockFlow',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 1,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//           const Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: CircleAvatar(
//               radius: 18,
//               backgroundColor: Color(0xFF0066CC),
//               child: Text(
//                 'EC',
//                 style: TextStyle(color: Colors.white, fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Greeting
//             const Text(
//               "Good morning, Chinedu 👋",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               "Here's what's happening with your business today",
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 24),

//             // Main KPI Cards (Today's Sales is prominent)
//             _buildMainSalesCard(currency.format(248750)),

//             const SizedBox(height: 20),

//             // Four Small Stats
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 1.7,
//               children: [
//                 _buildStatCard(
//                   "Total Products",
//                   "1,284",
//                   Icons.inventory_2,
//                   Colors.blue,
//                 ),
//                 _buildStatCard(
//                   "Low Stock",
//                   "12",
//                   Icons.warning_amber,
//                   Colors.orange,
//                 ),
//                 _buildStatCard(
//                   "Today's Orders",
//                   "28",
//                   Icons.shopping_cart,
//                   Colors.green,
//                 ),
//                 _buildStatCard(
//                   "Inventory Value",
//                   "₦1.8M",
//                   Icons.account_balance_wallet,
//                   Colors.purple,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 28),

//             // Sales Trend Chart
//             _buildSectionHeader("Sales Trend (Last 7 Days)"),
//             const SizedBox(height: 12),
//             _buildSalesLineChart(),

//             const SizedBox(height: 28),

//             // Low Stock Alerts
//             _buildSectionHeader("Low Stock Alerts"),
//             const SizedBox(height: 12),
//             _buildLowStockList(),

//             const SizedBox(height: 24),

//             // Quick Actions
//             _buildSectionHeader("Quick Actions"),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _quickActionButton(
//                     "Stock In",
//                     Icons.arrow_downward,
//                     Colors.green,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _quickActionButton(
//                     "Stock Out",
//                     Icons.arrow_upward,
//                     Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainSalesCard(String sales) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF0066CC), Color(0xFF3399FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Today's Sales",
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             sales,
//             style: const TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "+18% from yesterday",
//             style: TextStyle(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 28),
//           const Spacer(),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             title,
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSalesLineChart() {
//     return Container(
//       height: 220,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
//         ],
//       ),
//       child: LineChart(
//         LineChartData(
//           gridData: const FlGridData(show: true, horizontalInterval: 50),
//           titlesData: const FlTitlesData(show: false),
//           borderData: FlBorderData(show: false),
//           lineBarsData: [
//             LineChartBarData(
//               spots: const [
//                 FlSpot(0, 120),
//                 FlSpot(1, 98),
//                 FlSpot(2, 145),
//                 FlSpot(3, 168),
//                 FlSpot(4, 132),
//                 FlSpot(5, 210),
//                 FlSpot(6, 248),
//               ],
//               isCurved: true,
//               color: const Color(0xFF0066CC),
//               barWidth: 4,
//               dotData: const FlDotData(show: false),
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: const Color(0xFF0066CC).withOpacity(0.15),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLowStockList() {
//     return Column(
//       children: const [
//         _LowStockTile(
//           name: "Golden Penny Flour 50kg",
//           stock: "8 left",
//           level: "Critical",
//         ),
//         _LowStockTile(name: "Indomie Carton", stock: "15 left", level: "Low"),
//         _LowStockTile(
//           name: "Dangote Cement",
//           stock: "5 left",
//           level: "Critical",
//         ),
//       ],
//     );
//   }

//   Widget _quickActionButton(String label, IconData icon, Color color) {
//     return ElevatedButton.icon(
//       onPressed: () {},
//       icon: Icon(icon),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//     );
//   }
// }

// // Low Stock Tile Widget
// class _LowStockTile extends StatelessWidget {
//   final String name;
//   final String stock;
//   final String level;

//   const _LowStockTile({
//     required this.name,
//     required this.stock,
//     required this.level,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = level == "Critical" ? Colors.red : Colors.orange;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       child: ListTile(
//         title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
//         subtitle: Text(stock),
//         trailing: Chip(
//           label: Text(level, style: const TextStyle(fontSize: 12)),
//           backgroundColor: color.withOpacity(0.1),
//           labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/dashboard_screen.dart
//
// StockFlow Dashboard — clean, live, simple.
// Loads data safely step by step. No complex async chains.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  // ── colours ──────────────────────────────────────────────────────────────
  static const _blue = Color(0xFF0057FF);
  static const _blueSoft = Color(0xFFEBF1FF);
  static const _green = Color(0xFF00C17C);
  static const _greenSoft = Color(0xFFE6FAF3);
  static const _orange = Color(0xFFFF8C00);
  static const _orangeSoft = Color(0xFFFFF3E0);
  static const _purple = Color(0xFF7C3AED);
  static const _purpleSoft = Color(0xFFF3EDFF);
  static const _red = Color(0xFFE53935);
  static const _ink = Color(0xFF0D1B2A);
  static const _inkMid = Color(0xFF4A5568);
  static const _bg = Color(0xFFF4F7FB);
  static const _white = Colors.white;

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
        backgroundColor: _bg,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _blue))
              : _error.isNotEmpty
              ? _buildError()
              : RefreshIndicator(
                  color: _blue,
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
          const Icon(Icons.error_outline, color: _red, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Failed to load dashboard',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            _error,
            style: const TextStyle(color: _inkMid, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: _blue),
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
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(color: _inkMid, fontSize: 13),
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
                      color: _red,
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
                color: _blue,
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
        color: _white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: _ink),
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
            color: _blue.withOpacity(0.35),
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
                  color: Colors.white.withOpacity(0.15),
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
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
        children: [
          _kpiCard(
            'Products',
            '$_totalProducts',
            Icons.inventory_2_rounded,
            _blue,
            _blueSoft,
          ),
          _kpiCard(
            'Low Stock',
            '$_lowStockCount',
            Icons.warning_amber_rounded,
            _orange,
            _orangeSoft,
          ),
          _kpiCard(
            "Today's Orders",
            '$_todayOrders',
            Icons.shopping_cart_rounded,
            _green,
            _greenSoft,
          ),
          _kpiCard(
            'Inventory Value',
            _inventoryValue >= 1000000
                ? '₦${(_inventoryValue / 1000000).toStringAsFixed(1)}M'
                : '₦${(_inventoryValue / 1000).toStringAsFixed(0)}k',
            Icons.account_balance_wallet_rounded,
            _purple,
            _purpleSoft,
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
        color: _white,
        borderRadius: BorderRadius.circular(18),
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
              color: _ink,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: _inkMid)),
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
                          color: isToday ? _blue : _inkMid,
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
                              ? [_blue, const Color(0xFF3399FF)]
                              : [_blueSoft, _blueSoft],
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
                        color: isToday ? _blue : _inkMid,
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
            child: Text('No sales today yet', style: TextStyle(color: _inkMid)),
          ),
        ),
      );
    }

    final maxRev = _topItems.first.revenue;
    const colors = [_blue, _green, _orange, _purple];

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
                                color: _ink,
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
                          backgroundColor: const Color(0xFFEEF2F7),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.qty} unit${item.qty == 1 ? '' : 's'} sold',
                        style: const TextStyle(color: _inkMid, fontSize: 10),
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
      iconColor: _lowStockCount > 0 ? _orange : _green,
      trailing: _lowStockCount > 0
          ? GestureDetector(
              onTap: () => _go(const LowStockScreen()),
              child: Text(
                'View all $_lowStockCount →',
                style: const TextStyle(
                  color: _orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      child: _lowStockItems.isEmpty
          ? Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: _green, size: 18),
                SizedBox(width: 8),
                Text(
                  'All stock levels healthy!',
                  style: TextStyle(color: _green, fontWeight: FontWeight.w600),
                ),
              ],
            )
          : Column(
              children: _lowStockItems.map((p) {
                final stock = p['stock'] as int;
                final threshold = (p['alert_threshold'] as int?) ?? 10;
                final isOut = stock == 0;
                final color = isOut ? _red : _orange;
                final label = isOut ? 'Out' : 'Low';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
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
                                color: _ink,
                              ),
                            ),
                            Text(
                              '${p['brand']}  ·  $stock left',
                              style: const TextStyle(
                                color: _inkMid,
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
                          color: color.withOpacity(0.12),
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
    // final actions = [
    //   _Action(
    //     'Scan & Sell',
    //     Icons.qr_code_scanner_rounded,
    //     _blue,
    //     () => _go(const PosScreen()),
    //   ),
    //   _Action(
    //     'Products',
    //     Icons.inventory_2_rounded,
    //     _green,
    //     () => _go(const ProductsScreen()),
    //   ),
    //   _Action(
    //     'Sales',
    //     Icons.receipt_long_rounded,
    //     _purple,
    //     () => _go(const SalesHistoryScreen()),
    //   ),
    //   _Action(
    //     'Reports',
    //     Icons.bar_chart_rounded,
    //     _orange,
    //     () => _go(const ReportsScreen()),
    //   ),
    //   _Action(
    //     'Backup',
    //     Icons.backup_rounded,
    //     const Color(0xFF0099AA),
    //     () => _go(const BackupScreen()),
    //   ),
    //   _Action(
    //     'Alerts',
    //     Icons.warning_amber_rounded,
    //     _red,
    //     () => _go(const LowStockScreen()),
    //   ),
    //   _Action(
    //     'lock',
    //     Icons.warning_amber_rounded,
    //     _red,
    //     () => _go(LockScreen(onAuthenticated: () {})),
    //   ),
    // ];

    final actions = [
      _Action(
        'Scan & Sell',
        Icons.qr_code_scanner_rounded,
        _blue,
        () => _go(const PosScreen()),
      ),
      _Action(
        'Stock In',
        Icons.arrow_downward_rounded,
        _green,
        () => _go(const StockInScreen()),
      ), // NEW
      _Action(
        'Products',
        Icons.inventory_2_rounded,
        const Color(0xFF0099AA),
        () => _go(const ProductsScreen()),
      ),
      _Action(
        'Sales',
        Icons.receipt_long_rounded,
        _purple,
        () => _go(const SalesHistoryScreen()),
      ),
      _Action(
        'Sellers',
        Icons.group_rounded,
        _orange,
        () => _go(const SellersScreen()),
      ),

      if (SellerSession.instance.canViewReports)
        _Action(
          'Reports',
          Icons.bar_chart_rounded,
          const Color(0xFFE53935),
          () => _go(const ReportsScreen()),
        ),
      _Action(
        'Backup',
        Icons.backup_rounded,
        const Color(0xFF0099AA),
        () => _go(const BackupScreen()),
      ),

      // _Action(
      //   'Settings',
      //   Icons.settings_rounded,
      //   const Color(0xFF4A5568),
      //   () => _go(const SettingsScreen()),
      // ),
      if (SellerSession.instance.canAccessSettings)
        _Action(
          'Settings',
          Icons.settings_rounded,
          const Color(0xFF4A5568),
          () => _go(const SettingsScreen()),
        ),

      _Action(
        'Cashiers',
        Icons.people_rounded,
        const Color(0xFF0099AA),
        () => _go(const SellersScreen()),
      ),

      _Action(
        'Stock In',
        Icons.arrow_downward_rounded,
        const Color(0xFF0099AA),
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
                    color: a.color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: a.color.withOpacity(0.18)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.12),
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
    Color iconColor = _ink,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: _ink,
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
