// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),

//       /// APP BAR (UI only)
//       appBar: AppBar(
//         title: const Text(
//           'StockFlow',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//           IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
//         ],
//       ),

//       /// BODY
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             _StatsGrid(),
//             SizedBox(height: 24),
//             _SectionHeader(title: "Stock overview"),
//             SizedBox(height: 12),
//             _InventoryChart(),
//             SizedBox(height: 24),
//             _SectionHeader(title: "Low stock alerts"),
//             SizedBox(height: 12),
//             _LowStockList(),
//             SizedBox(height: 24),
//             _SectionHeader(title: "Recent transactions"),
//             SizedBox(height: 12),
//             _TransactionList(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //
// // ─────────────────────────────────────────────
// //  STATS GRID (UI ONLY)
// // ─────────────────────────────────────────────
// //
// class _StatsGrid extends StatelessWidget {
//   const _StatsGrid();

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       childAspectRatio: 1.5,
//       children: const [
//         _StatCard(title: "Total products", value: "120"),
//         _StatCard(title: "Inventory value", value: "₦250,000"),
//         _StatCard(title: "Low stock items", value: "5"),
//         _StatCard(title: "Out of stock", value: "2"),
//       ],
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;

//   const _StatCard({required this.title, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Icon(Icons.bar_chart, color: Colors.blue),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 title,
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// //
// // ─────────────────────────────────────────────
// //  INVENTORY CHART (STATIC UI ONLY)
// // ─────────────────────────────────────────────
// //
// class _InventoryChart extends StatelessWidget {
//   const _InventoryChart();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: BarChart(
//         BarChartData(
//           barGroups: List.generate(
//             6,
//             (i) => BarChartGroupData(
//               x: i,
//               barRods: [
//                 BarChartRodData(
//                   toY: (i + 1) * 3.0,
//                   width: 18,
//                   color: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//           gridData: const FlGridData(show: false),
//           titlesData: const FlTitlesData(show: false),
//           borderData: FlBorderData(show: false),
//         ),
//       ),
//     );
//   }
// }

// //
// // ─────────────────────────────────────────────
// //  LOW STOCK LIST (UI ONLY)
// // ─────────────────────────────────────────────
// //
// class _LowStockList extends StatelessWidget {
//   const _LowStockList();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: const [
//         _SimpleTile(title: "Rice", subtitle: "Qty: 3"),
//         _SimpleTile(title: "Milk", subtitle: "Qty: 2"),
//         _SimpleTile(title: "Sugar", subtitle: "Qty: 1"),
//       ],
//     );
//   }
// }

// //
// // ─────────────────────────────────────────────
// //  TRANSACTIONS LIST (UI ONLY)
// // ─────────────────────────────────────────────
// //
// class _TransactionList extends StatelessWidget {
//   const _TransactionList();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: const [
//         _SimpleTile(title: "Rice sold", subtitle: "+5"),
//         _SimpleTile(title: "Milk added", subtitle: "+10"),
//         _SimpleTile(title: "Sugar sold", subtitle: "-2"),
//       ],
//     );
//   }
// }

// //
// // ─────────────────────────────────────────────
// //  SIMPLE TILE (REUSED UI)
// // ─────────────────────────────────────────────
// //
// class _SimpleTile extends StatelessWidget {
//   final String title;
//   final String subtitle;

//   const _SimpleTile({required this.title, required this.subtitle});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.circle, size: 10, color: Colors.grey),
//           const SizedBox(width: 12),
//           Expanded(child: Text(title)),
//           Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
//         ],
//       ),
//     );
//   }
// }

// //
// // ─────────────────────────────────────────────
// //  SECTION HEADER
// // ─────────────────────────────────────────────
// //
// class _SectionHeader extends StatelessWidget {
//   final String title;

//   const _SectionHeader({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'StockFlow',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF0066CC),
              child: Text(
                'EC',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            const Text(
              "Good morning, Chinedu 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Here's what's happening with your business today",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Main KPI Cards (Today's Sales is prominent)
            _buildMainSalesCard(currency.format(248750)),

            const SizedBox(height: 20),

            // Four Small Stats
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _buildStatCard(
                  "Total Products",
                  "1,284",
                  Icons.inventory_2,
                  Colors.blue,
                ),
                _buildStatCard(
                  "Low Stock",
                  "12",
                  Icons.warning_amber,
                  Colors.orange,
                ),
                _buildStatCard(
                  "Today's Orders",
                  "28",
                  Icons.shopping_cart,
                  Colors.green,
                ),
                _buildStatCard(
                  "Inventory Value",
                  "₦1.8M",
                  Icons.account_balance_wallet,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Sales Trend Chart
            _buildSectionHeader("Sales Trend (Last 7 Days)"),
            const SizedBox(height: 12),
            _buildSalesLineChart(),

            const SizedBox(height: 28),

            // Low Stock Alerts
            _buildSectionHeader("Low Stock Alerts"),
            const SizedBox(height: 12),
            _buildLowStockList(),

            const SizedBox(height: 24),

            // Quick Actions
            _buildSectionHeader("Quick Actions"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _quickActionButton(
                    "Stock In",
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionButton(
                    "Stock Out",
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSalesCard(String sales) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066CC), Color(0xFF3399FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Sales",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            sales,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "+18% from yesterday",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesLineChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, horizontalInterval: 50),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 120),
                FlSpot(1, 98),
                FlSpot(2, 145),
                FlSpot(3, 168),
                FlSpot(4, 132),
                FlSpot(5, 210),
                FlSpot(6, 248),
              ],
              isCurved: true,
              color: const Color(0xFF0066CC),
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF0066CC).withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList() {
    return Column(
      children: const [
        _LowStockTile(
          name: "Golden Penny Flour 50kg",
          stock: "8 left",
          level: "Critical",
        ),
        _LowStockTile(name: "Indomie Carton", stock: "15 left", level: "Low"),
        _LowStockTile(
          name: "Dangote Cement",
          stock: "5 left",
          level: "Critical",
        ),
      ],
    );
  }

  Widget _quickActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    );
  }
}

// Low Stock Tile Widget
class _LowStockTile extends StatelessWidget {
  final String name;
  final String stock;
  final String level;

  const _LowStockTile({
    required this.name,
    required this.stock,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final color = level == "Critical" ? Colors.red : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(stock),
        trailing: Chip(
          label: Text(level, style: const TextStyle(fontSize: 12)),
          backgroundColor: color.withOpacity(0.1),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
