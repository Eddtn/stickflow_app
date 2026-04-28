import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          TextButton.icon(
            onPressed: () => _pickDateRange(context),
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              _dateRange == null
                  ? "All time"
                  : "${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _ExportSection(),
            SizedBox(height: 24),
            _PieChartSection(),
            SizedBox(height: 24),
            _LineChartSection(),
            SizedBox(height: 24),
            _TopProductsSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}

//
// ─────────────────────────────────────────────
//  EXPORT BUTTONS
// ─────────────────────────────────────────────
//
class _ExportSection extends StatelessWidget {
  const _ExportSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _ExportBtn(
                label: "Export Inventory PDF",
                color: Colors.red,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ExportBtn(
                label: "Export Inventory CSV",
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _ExportBtn(label: "Export Transactions PDF", color: Colors.blue),
      ],
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final String label;
  final Color color;

  const _ExportBtn({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.file_copy, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: color),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  PIE CHART (STATIC)
// ─────────────────────────────────────────────
//
class _PieChartSection extends StatelessWidget {
  const _PieChartSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text("Inventory Overview"),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 60, color: Colors.green),
                  PieChartSectionData(value: 25, color: Colors.orange),
                  PieChartSectionData(value: 15, color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  LINE CHART (STATIC)
// ─────────────────────────────────────────────
//
class _LineChartSection extends StatelessWidget {
  const _LineChartSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text("Stock Movements"),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 5),
                      FlSpot(2, 3),
                      FlSpot(3, 7),
                      FlSpot(4, 4),
                    ],
                    isCurved: true,
                  ),
                ],
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  TOP PRODUCTS
// ─────────────────────────────────────────────
//
class _TopProductsSection extends StatelessWidget {
  const _TopProductsSection();

  @override
  Widget build(BuildContext context) {
    final items = [
      {"name": "Laptop", "value": "₦500,000"},
      {"name": "Phone", "value": "₦300,000"},
      {"name": "Rice", "value": "₦200,000"},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: Text(item["name"]!)),
                Text(item["value"]!),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
