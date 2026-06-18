import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/products/product_model/prod_model.dart';
import 'dart:io';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);
const _kDanger = Color(0xFFFF5370);

enum _LabelSize { small, medium, large }

enum _BarcodeType { barcode, qr }

// ─────────────────────────────────────────────
//  BARCODE LABELS SCREEN
// ─────────────────────────────────────────────
class BarcodeLabelsScreen extends StatefulWidget {
  /// If provided, only this product's label is shown (single-label mode).
  /// If null, all products are loaded from the database.
  final Product? singleProduct;

  const BarcodeLabelsScreen({super.key, this.singleProduct});

  @override
  State<BarcodeLabelsScreen> createState() => _BarcodeLabelsScreenState();
}

class _BarcodeLabelsScreenState extends State<BarcodeLabelsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  final _searchCtrl = TextEditingController();

  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = true;

  _LabelSize _labelSize = _LabelSize.medium;
  _BarcodeType _barcodeType = _BarcodeType.barcode;

  // One GlobalKey per product for screenshot capture
  final Map<int, GlobalKey> _repaintKeys = {};

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
    final products = widget.singleProduct != null
        ? [widget.singleProduct!]
        : (await _db.getAllProducts()).map(Product.fromMap).toList();
    setState(() {
      _products = products;
      _filtered = products;
      _loading = false;
      for (final p in products) {
        _repaintKeys[p.id!] = GlobalKey();
      }
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

  // ── Capture one label as PNG bytes ────────────────────────────────────────
  Future<Uint8List?> _captureLabel(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  // ── Share a single label ──────────────────────────────────────────────────
  Future<void> _shareLabel(Product p) async {
    final key = _repaintKeys[p.id!];
    if (key == null) return;

    HapticFeedback.mediumImpact();
    final bytes = await _captureLabel(key);
    if (bytes == null) {
      _showSnack('Could not capture label', isError: true);
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/label_${p.barcode}.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${p.name} — ${p.brand}\nBarcode: ${p.barcode}',
      subject: 'Product Label: ${p.name}',
    );
  }

  // ── Save label to downloads ───────────────────────────────────────────────
  Future<void> _saveLabel(Product p) async {
    final key = _repaintKeys[p.id!];
    if (key == null) return;

    HapticFeedback.mediumImpact();
    final bytes = await _captureLabel(key);
    if (bytes == null) {
      _showSnack('Could not capture label', isError: true);
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final labelsDir = Directory('${dir.path}/labels');
      if (!labelsDir.existsSync()) labelsDir.createSync();
      final file = File('${labelsDir.path}/label_${p.barcode}.png');
      await file.writeAsBytes(bytes);
      _showSnack('Label saved to ${file.path}');
    } catch (e) {
      _showSnack('Failed to save label', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _kDanger : _kAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Label dimensions ──────────────────────────────────────────────────────
  double get _labelWidth {
    switch (_labelSize) {
      case _LabelSize.small:
        return 160;
      case _LabelSize.medium:
        return 220;
      case _LabelSize.large:
        return 300;
    }
  }

  double get _barcodeHeight {
    switch (_labelSize) {
      case _LabelSize.small:
        return 48;
      case _LabelSize.medium:
        return 68;
      case _LabelSize.large:
        return 90;
    }
  }

  double get _fontSize {
    switch (_labelSize) {
      case _LabelSize.small:
        return 9;
      case _LabelSize.medium:
        return 11;
      case _LabelSize.large:
        return 13;
    }
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _kTextDim,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Label Generator',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kAccent.withOpacity(0.3)),
                ),
                child: Text(
                  '${_filtered.length} label${_filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _kAccent))
            : Column(
                children: [
                  _buildControls(),
                  _buildSearchBar(),
                  Expanded(child: _buildGrid()),
                ],
              ),
      ),
    );
  }

  // ── Controls row: barcode type + label size ───────────────────────────────
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          // Barcode type toggle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TYPE',
                  style: TextStyle(
                    color: _kTextDim,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _typeBtn(
                        'Barcode',
                        _BarcodeType.barcode,
                        Icons.barcode_reader,
                      ),
                      _typeBtn(
                        'QR Code',
                        _BarcodeType.qr,
                        Icons.qr_code_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Label size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SIZE',
                  style: TextStyle(
                    color: _kTextDim,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _sizeBtn('S', _LabelSize.small),
                      _sizeBtn('M', _LabelSize.medium),
                      _sizeBtn('L', _LabelSize.large),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBtn(String label, _BarcodeType type, IconData icon) {
    final active = _barcodeType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _barcodeType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? _kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: active ? _kBg : _kTextDim),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? _kBg : _kTextDim,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizeBtn(String label, _LabelSize size) {
    final active = _labelSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _labelSize = size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? _kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? _kBg : _kTextDim,
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        style: const TextStyle(color: _kText, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search products…',
          hintStyle: const TextStyle(color: _kTextDim, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _kTextDim,
            size: 18,
          ),
          filled: true,
          fillColor: _kCard,
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
              color: _kAccent.withOpacity(0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── Label grid ────────────────────────────────────────────────────────────
  Widget _buildGrid() {
    if (_filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_off_rounded, color: _kTextDim, size: 48),
            SizedBox(height: 14),
            Text(
              'No products found',
              style: TextStyle(color: _kText, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) => _buildLabelCard(_filtered[i]),
    );
  }

  // ── Individual label card ─────────────────────────────────────────────────
  Widget _buildLabelCard(Product p) {
    final key = _repaintKeys[p.id!] ?? GlobalKey();

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // ── Label preview (capturable) ──────────────────────────────────
          Expanded(
            child: RepaintBoundary(key: key, child: _buildLabelPreview(p)),
          ),

          // ── Action buttons ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () => _shareLabel(p),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionBtn(
                    icon: Icons.download_rounded,
                    label: 'Save',
                    color: _kAccent,
                    onTap: () => _saveLabel(p),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── The printable label itself ─────────────────────────────────────────────
  Widget _buildLabelPreview(Product p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Store name
          Text(
            'STOCKFLOW',
            style: TextStyle(
              color: const Color(0xFF0A0F1E),
              fontSize: _fontSize - 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),

          // Product icon + name
          Text(
            '${p.icon}  ${p.name}',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF1C2539),
              fontSize: _fontSize + 1,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          Text(
            p.brand,
            style: TextStyle(
              color: const Color(0xFF8892A4),
              fontSize: _fontSize - 1,
            ),
          ),
          const SizedBox(height: 8),

          // Barcode or QR
          _barcodeType == _BarcodeType.barcode
              ? BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: p.barcode,
                  width: _labelWidth,
                  height: _barcodeHeight,
                  style: TextStyle(
                    fontSize: _fontSize - 2,
                    color: const Color(0xFF0A0F1E),
                  ),
                  color: const Color(0xFF0A0F1E),
                  backgroundColor: Colors.transparent,
                )
              : BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: p.barcode,
                  width: _barcodeHeight + 10,
                  height: _barcodeHeight + 10,
                  color: const Color(0xFF0A0F1E),
                  backgroundColor: Colors.transparent,
                ),

          const SizedBox(height: 6),

          // Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5A0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '₦${_formatPrice(p.price)}',
              style: TextStyle(
                color: const Color(0xFF0A0F1E),
                fontSize: _fontSize + 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Barcode number text
          Text(
            p.barcode,
            style: TextStyle(
              color: const Color(0xFF8892A4),
              fontSize: _fontSize - 2,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = _kTextDim,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
