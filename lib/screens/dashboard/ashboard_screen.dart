import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      /// APP BAR (UI only)
      appBar: AppBar(
        title: const Text(
          'StockFlow',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _StatsGrid(),
            SizedBox(height: 24),
            _SectionHeader(title: "Stock overview"),
            SizedBox(height: 12),
            _InventoryChart(),
            SizedBox(height: 24),
            _SectionHeader(title: "Low stock alerts"),
            SizedBox(height: 12),
            _LowStockList(),
            SizedBox(height: 24),
            _SectionHeader(title: "Recent transactions"),
            SizedBox(height: 12),
            _TransactionList(),
          ],
        ),
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  STATS GRID (UI ONLY)
// ─────────────────────────────────────────────
//
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: const [
        _StatCard(title: "Total products", value: "120"),
        _StatCard(title: "Inventory value", value: "₦250,000"),
        _StatCard(title: "Low stock items", value: "5"),
        _StatCard(title: "Out of stock", value: "2"),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.bar_chart, color: Colors.blue),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  INVENTORY CHART (STATIC UI ONLY)
// ─────────────────────────────────────────────
//
class _InventoryChart extends StatelessWidget {
  const _InventoryChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          barGroups: List.generate(
            6,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (i + 1) * 3.0,
                  width: 18,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  LOW STOCK LIST (UI ONLY)
// ─────────────────────────────────────────────
//
class _LowStockList extends StatelessWidget {
  const _LowStockList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SimpleTile(title: "Rice", subtitle: "Qty: 3"),
        _SimpleTile(title: "Milk", subtitle: "Qty: 2"),
        _SimpleTile(title: "Sugar", subtitle: "Qty: 1"),
      ],
    );
  }
}

//
// ─────────────────────────────────────────────
//  TRANSACTIONS LIST (UI ONLY)
// ─────────────────────────────────────────────
//
class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SimpleTile(title: "Rice sold", subtitle: "+5"),
        _SimpleTile(title: "Milk added", subtitle: "+10"),
        _SimpleTile(title: "Sugar sold", subtitle: "-2"),
      ],
    );
  }
}

//
// ─────────────────────────────────────────────
//  SIMPLE TILE (REUSED UI)
// ─────────────────────────────────────────────
//
class _SimpleTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SimpleTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────
//
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
