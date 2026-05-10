import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Product Details"),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _ProductHeaderCard(),
            SizedBox(height: 12),
            _StatsRow(),
            SizedBox(height: 12),
            _AlertCard(),
            SizedBox(height: 20),
            _ActionRow(),
            SizedBox(height: 24),
            _SectionHeader(title: "Transaction history"),
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
//  PRODUCT HEADER
// ─────────────────────────────────────────────
//
class _ProductHeaderCard extends StatelessWidget {
  const _ProductHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text("SKU: DEMO-001"),
                Text("Category: Electronics"),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "In Stock",
              style: TextStyle(fontSize: 11, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  STATS ROW
// ─────────────────────────────────────────────
//
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _InfoTile(label: "Stock", value: "120"),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _InfoTile(label: "Price", value: "₦5,000"),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _InfoTile(label: "Value", value: "₦600,000"),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  ALERT CARD
// ─────────────────────────────────────────────
//
class _AlertCard extends StatelessWidget {
  const _AlertCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: Colors.orange),
          SizedBox(width: 8),
          Text("Low stock alert at 5 units"),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  ACTION ROW
// ─────────────────────────────────────────────
//
class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ActionButton(label: "Stock In", color: Colors.green),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ActionButton(label: "Stock Out", color: Colors.orange),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;

  const _ActionButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//
// ─────────────────────────────────────────────
//  TRANSACTIONS (STATIC UI)
// ─────────────────────────────────────────────
//
class _TransactionList extends StatelessWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TxTile(title: "Stock In", qty: "+10"),
        _TxTile(title: "Stock Out", qty: "-2"),
        _TxTile(title: "Stock In", qty: "+5"),
      ],
    );
  }
}

class _TxTile extends StatelessWidget {
  final String title;
  final String qty;

  const _TxTile({required this.title, required this.qty});

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
          const Icon(Icons.swap_horiz),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(qty),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
