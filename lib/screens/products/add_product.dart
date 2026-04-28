import 'package:flutter/material.dart';
import 'package:stockflow/core/constant.dart';

class AddProductScreen extends StatefulWidget {
  final bool isEdit;

  const AddProductScreen({super.key, this.isEdit = false});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // UI-only placeholders (no real data binding)
    _qtyCtrl.text = "0";
    _thresholdCtrl.text = "5";
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _categoryCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Product" : "Add Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────
              // IMAGE PICKER (UI ONLY)
              // ─────────────────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Add photo",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _label("Product name *"),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: "e.g. Industrial Bolt M8",
                ),
              ),

              const SizedBox(height: 16),

              _label("SKU / Barcode *"),
              TextFormField(
                controller: _skuCtrl,
                decoration: const InputDecoration(
                  hintText: "e.g. BOLT-M8-001",
                  suffixIcon: Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _label("Category *"),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  hintText: "e.g. Fasteners, Electronics",
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Initial quantity *"),
                        TextFormField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: "0"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Low stock alert at *"),
                        TextFormField(
                          controller: _thresholdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: "5"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _label("Unit price (₦) *"),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: "0.00",
                  prefixText: "₦ ",
                ),
              ),

              const SizedBox(height: 32),

              // ─────────────────────────────
              // SUBMIT BUTTON (UI ONLY)
              // ─────────────────────────────
              ElevatedButton(
                onPressed: () {
                  // UI ONLY - no logic
                },
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.isEdit ? "Update Product" : "Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
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
