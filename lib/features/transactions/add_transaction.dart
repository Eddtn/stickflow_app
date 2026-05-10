import 'package:flutter/material.dart';
import 'package:stockflow/core/constant.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool isStockIn = true;
  String? selectedProduct;

  final List<String> dummyProducts = [
    'Industrial Bolt M8',
    'Steel Pipe 2-inch',
    'Hydraulic Pump',
  ];

  final reasons = {
    true: [
      'Purchase',
      'Return from customer',
      'Production output',
      'Adjustment',
      'Other',
    ],
    false: [
      'Sale',
      'Damaged goods',
      'Returned to supplier',
      'Internal use',
      'Adjustment',
      'Other',
    ],
  };

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Record Stock Movement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Type toggle ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _TypeBtn(
                      label: 'Stock In',
                      icon: Icons.arrow_downward,
                      color: AppColors.success,
                      selected: isStockIn,
                      onTap: () => setState(() {
                        isStockIn = true;
                        _reasonCtrl.clear();
                      }),
                    ),
                    _TypeBtn(
                      label: 'Stock Out',
                      icon: Icons.arrow_upward,
                      color: AppColors.warning,
                      selected: !isStockIn,
                      onTap: () => setState(() {
                        isStockIn = false;
                        _reasonCtrl.clear();
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Product selector ─────────────────────────
              _Label('Select product *'),
              DropdownButtonFormField<String>(
                value: selectedProduct,
                hint: const Text('Choose a product'),
                items: dummyProducts
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => selectedProduct = v),
                validator: (v) => v == null ? 'Please select a product' : null,
              ),

              const SizedBox(height: 16),

              // ─── Quantity ────────────────────────────────
              _Label('Quantity *'),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Enter quantity'),
              ),

              const SizedBox(height: 16),

              // ─── Reason ─────────────────────────────────
              _Label('Reason *'),
              DropdownButtonFormField<String>(
                value: reasons[isStockIn]!.contains(_reasonCtrl.text)
                    ? _reasonCtrl.text
                    : null,
                hint: const Text('Select a reason'),
                items: reasons[isStockIn]!
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _reasonCtrl.text = v ?? ''),
              ),

              const SizedBox(height: 16),

              // ─── Note ───────────────────────────────────
              _Label('Note (optional)'),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Additional details...',
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  // UI only — no logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isStockIn
                      ? AppColors.success
                      : AppColors.warning,
                ),
                child: Text(
                  isStockIn ? 'Confirm Stock In' : 'Confirm Stock Out',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? color : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
