// lib/screens/stock_in_screen.dart
//
// Stock In — quickly restock one or many products
// without going through the products edit screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/products/product_model/prod_model.dart';

const _kBg = Color(0xFFF0F4F8);
const _kWhite = Colors.white;
const _kBlue = Color(0xFF0057FF);
const _kGreen = Color(0xFF00C17C);
const _kRed = Color(0xFFE53935);
const _kOrange = Color(0xFFFF8C00);
const _kInk = Color(0xFF0D1B2A);
const _kInkMid = Color(0xFF4A5568);
const _kInkSoft = Color(0xFFCBD5E0);
const _kBorder = Color(0xFFEEF2F7);

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final _db = DatabaseHelper.instance;
  final _searchCtrl = TextEditingController();

  List<Product> _products = [];
  List<Product> _filtered = [];
  final Map<int, int> _quantities = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _db.getAllProducts();
    final products = rows.map(Product.fromMap).toList();
    setState(() {
      _products = products;
      _filtered = products;
      _loading = false;
    });
  }

  void _onSearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _products
          : _products
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(query) ||
                      p.brand.toLowerCase().contains(query) ||
                      p.barcode.contains(query),
                )
                .toList();
    });
  }

  void _increment(int id) =>
      setState(() => _quantities[id] = (_quantities[id] ?? 0) + 1);

  void _decrement(int id) {
    final cur = _quantities[id] ?? 0;
    if (cur <= 0) return;
    setState(() => _quantities[id] = cur - 1);
  }

  int get _totalItemsToRestock => _quantities.values.fold(0, (s, q) => s + q);

  Future<void> _confirmRestock() async {
    final toRestock = _quantities.entries.where((e) => e.value > 0).toList();

    if (toRestock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No quantities set. Adjust amounts first.'),
          backgroundColor: _kOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final lines = toRestock
        .map((e) {
          final p = _products.firstWhere((p) => p.id == e.key);
          return '${p.name}: +${e.value}';
        })
        .join('\n');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Confirm Restock',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Add the following stock?\n\n$lines',
          style: const TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: _kGreen, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _saving = true);

    final db = await _db.database;
    for (final entry in toRestock) {
      await db.rawUpdate('UPDATE products SET stock = stock + ? WHERE id = ?', [
        entry.value,
        entry.key,
      ]);
    }

    setState(() {
      _quantities.clear();
      _saving = false;
    });
    await _load();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅  Restocked ${toRestock.length} product${toRestock.length == 1 ? "" : "s"}',
          ),
          backgroundColor: _kGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

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
          'Stock In',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: _kInk,
          ),
        ),
        actions: [
          if (_totalItemsToRestock > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _saving ? null : _confirmRestock,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _kGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Restock ($_totalItemsToRestock)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            color: _kWhite,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGreen.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: _kGreen, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Set the quantity to ADD to each product, then tap Restock.',
                      style: TextStyle(
                        color: _kGreen,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: _kInk, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search products…',
                hintStyle: const TextStyle(color: _kInkSoft, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _kInkMid,
                  size: 18,
                ),
                filled: true,
                fillColor: _kWhite,
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
                    color: _kBlue.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _kBlue))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _buildRow(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Product p) {
    final qty = _quantities[p.id!] ?? 0;
    final hasQty = qty > 0;
    final isLow = p.stock <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasQty ? _kGreen.withOpacity(0.4) : _kBorder,
          width: hasQty ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(p.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    color: _kInk,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.brand}  ·  ${p.category}',
                  style: const TextStyle(color: _kInkMid, fontSize: 11),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _stockBadge(
                      'Stock: ${p.stock}',
                      isLow ? _kOrange : _kGreen,
                    ),
                    if (hasQty) ...[
                      const SizedBox(width: 6),
                      _stockBadge('→ ${p.stock + qty} after', _kGreen),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // +/- control
          Container(
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasQty ? _kGreen.withOpacity(0.4) : _kBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _qBtn(Icons.remove, () => _decrement(p.id!), qty > 0),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '$qty',
                    style: TextStyle(
                      color: hasQty ? _kGreen : _kInkMid,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _qBtn(Icons.add, () => _increment(p.id!), true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );

  Widget _qBtn(IconData icon, VoidCallback onTap, bool enabled) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icon, size: 16, color: enabled ? _kInk : _kInkSoft),
        ),
      );
}
