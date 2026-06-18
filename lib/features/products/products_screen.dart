import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/posscreen/barcode_label_screen.dart';
import 'package:stockflow/features/products/product_model/prod_model.dart';

// ── Theme (matches POS screen) ─────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kDanger = Color(0xFFFF5370);
const _kWarning = Color(0xFFFFB547);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

const List<String> _kIcons = [
  '📦',
  '🌾',
  '🍜',
  '🥛',
  '🍬',
  '🏗️',
  '🧼',
  '🍶',
  '🥤',
  '🧃',
  '🍖',
  '🥚',
  '🧂',
  '🫙',
  '🧴',
  '🪣',
  '💊',
  '🩺',
  '📱',
  '💡',
  '🔋',
  '🧹',
  '🪴',
  '🎒',
];

const List<String> _kCategories = [
  'Grains',
  'Noodles',
  'Dairy',
  'Sweeteners',
  'Building Materials',
  'Cleaning',
  'Beverages',
  'Snacks',
  'Frozen Foods',
  'Personal Care',
  'Electronics',
  'Stationery',
  'Other',
];

// ─────────────────────────────────────────────
//  PRODUCTS SCREEN
// ─────────────────────────────────────────────
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _db = DatabaseHelper.instance;
  final _searchCtrl = TextEditingController();

  List<Product> _products = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final rows = _searchQuery.isEmpty
        ? await _db.getAllProducts()
        : await _db.searchProducts(_searchQuery);
    setState(() {
      _products = rows.map(Product.fromMap).toList();
      _loading = false;
    });
  }

  void _onSearch(String q) {
    _searchQuery = q.trim();
    _loadProducts();
  }

  Future<void> _deleteProduct(Product p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Product',
        message: 'Remove "${p.name}" from your inventory?',
      ),
    );
    if (confirm == true) {
      await _db.deleteProduct(p.id!);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${p.name} deleted'),
            backgroundColor: _kDanger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _openProductForm({Product? product}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(product: product),
    );
    if (saved == true) _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _kBg),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          // leading: IconButton(
          //   icon: const Icon(
          //     Icons.arrow_back_ios_new_rounded,
          //     color: _kTextDim,
          //   ),
          //   onPressed: () => Navigator.pop(context),
          // ),
          title: const Text(
            'Products',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _openProductForm(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _kAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: _kBg, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: _kBg,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStats(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        style: const TextStyle(color: _kText, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by name, brand, barcode…',
          hintStyle: const TextStyle(color: _kTextDim, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _kTextDim,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: _kTextDim,
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: _kCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: _kAccent.withOpacity(0.5),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalValue = _products.fold<int>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final lowStock = _products.where((p) => p.stock < 10).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _statChip(
            '${_products.length}',
            'Products',
            Icons.inventory_2_rounded,
          ),
          const SizedBox(width: 10),
          _statChip(
            '₦${_formatPrice(totalValue)}',
            'Stock Value',
            Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(width: 10),
          _statChip(
            '$lowStock',
            'Low Stock',
            Icons.warning_amber_rounded,
            color: lowStock > 0 ? _kWarning : _kAccent,
          ),
        ],
      ),
    );
  }

  Widget _statChip(
    String value,
    String label,
    IconData icon, {
    Color color = _kAccent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(label, style: const TextStyle(color: _kTextDim, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _kAccent));
    }
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, color: _kTextDim, size: 56),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No products yet' : 'No results found',
              style: const TextStyle(
                color: _kText,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isEmpty
                  ? 'Tap + Add to create your first product'
                  : 'Try a different search term',
              style: const TextStyle(color: _kTextDim, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _products.length,
      itemBuilder: (ctx, i) => _buildProductCard(_products[i]),
    );
  }

  Widget _buildProductCard(Product p) {
    final isLowStock = p.stock < 10;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock
              ? _kWarning.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _kAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(p.icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          p.name,
          style: const TextStyle(
            color: _kText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              '${p.brand} · ${p.category}',
              style: const TextStyle(color: _kTextDim, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₦${_formatPrice(p.price)}',
                  style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? _kWarning.withOpacity(0.15)
                        : _kAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${p.stock} in stock',
                    style: TextStyle(
                      color: isLowStock ? _kWarning : _kAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.barcode,
                  style: const TextStyle(color: _kTextDim, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBtn(
              icon: Icons.edit_rounded,
              color: _kAccent,
              onTap: () => _openProductForm(product: p),
            ),
            const SizedBox(width: 4),
            _iconBtn(
              icon: Icons.delete_outline_rounded,
              color: _kDanger,
              onTap: () => _deleteProduct(p),
            ),
            const SizedBox(width: 4),
            _iconBtn(
              icon: Icons.label_rounded,
              color: const Color(0xFF7C9FFF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BarcodeLabelsScreen(singleProduct: p),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  String _formatPrice(int price) {
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
//  PRODUCT FORM BOTTOM SHEET
// ─────────────────────────────────────────────
class ProductFormSheet extends StatefulWidget {
  final Product? product;
  const ProductFormSheet({super.key, this.product});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;

  late TextEditingController _barcodeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;

  String _selectedCategory = _kCategories.first;
  String _selectedIcon = '📦';
  bool _saving = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _priceCtrl = TextEditingController(text: p != null ? '${p.price}' : '');
    _stockCtrl = TextEditingController(text: p != null ? '${p.stock}' : '');
    _selectedCategory = p?.category ?? _kCategories.first;
    _selectedIcon = p?.icon ?? '📦';
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final product = Product(
      id: widget.product?.id,
      barcode: _barcodeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      category: _selectedCategory,
      price: int.parse(_priceCtrl.text.trim()),
      stock: int.parse(_stockCtrl.text.trim()),
      icon: _selectedIcon,
    );

    try {
      if (_isEditing) {
        await _db.updateProduct(product.toMap());
      } else {
        await _db.insertProduct(product.toMap());
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('UNIQUE')
                  ? 'Barcode already exists!'
                  : 'Error saving product',
            ),
            backgroundColor: _kDanger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _isEditing ? 'Edit Product' : 'Add New Product',
                style: const TextStyle(
                  color: _kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // Icon picker
              _label('Product Icon'),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kIcons.length,
                  itemBuilder: (ctx, i) {
                    final ic = _kIcons[i];
                    final selected = ic == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = ic),
                      child: Container(
                        width: 46,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selected ? _kAccent.withOpacity(0.2) : _kCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? _kAccent
                                : Colors.white.withOpacity(0.06),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(ic, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Barcode
              _label('Barcode / QR Code'),
              const SizedBox(height: 6),
              _field(
                controller: _barcodeCtrl,
                hint: 'e.g. 123456789',
                enabled: !_isEditing, // barcode is immutable when editing
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter barcode';
                  if (v.trim().length < 6) return 'Barcode too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Name
              _label('Product Name'),
              const SizedBox(height: 6),
              _field(
                controller: _nameCtrl,
                hint: 'e.g. Rice 5kg',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 12),

              // Brand
              _label('Brand'),
              const SizedBox(height: 6),
              _field(
                controller: _brandCtrl,
                hint: 'e.g. Golden Penny',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter brand' : null,
              ),
              const SizedBox(height: 12),

              // Category dropdown
              _label('Category'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: _kCard,
                    style: const TextStyle(color: _kText, fontSize: 14),
                    icon: const Icon(
                      Icons.expand_more_rounded,
                      color: _kTextDim,
                    ),
                    items: _kCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Price & Stock row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Price (₦)'),
                        const SizedBox(height: 6),
                        _field(
                          controller: _priceCtrl,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Enter price';
                            if (int.tryParse(v) == null || int.parse(v) <= 0)
                              return 'Invalid price';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Stock Qty'),
                        const SizedBox(height: 6),
                        _field(
                          controller: _stockCtrl,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Enter stock';
                            if (int.tryParse(v) == null) return 'Invalid qty';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    disabledBackgroundColor: _kAccent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: _kBg,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Add Product',
                          style: const TextStyle(
                            color: _kBg,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: _kTextDim,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: enabled ? _kText : _kTextDim, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kTextDim, fontSize: 14),
        filled: true,
        fillColor: enabled ? _kCard : _kCard.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _kAccent.withOpacity(0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDanger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDanger, width: 1.5),
        ),
        errorStyle: const TextStyle(color: _kDanger, fontSize: 11),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CONFIRM DIALOG
// ─────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  const _ConfirmDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(color: _kText, fontWeight: FontWeight.w700),
      ),
      content: Text(message, style: const TextStyle(color: _kTextDim)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: _kTextDim)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: _kDanger, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
