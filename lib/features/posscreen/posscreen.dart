import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/posscreen/barcode_label_screen.dart';
import 'package:stockflow/features/reports/reports_screen.dart';
import 'package:stockflow/features/sales_history/sales_history.dart';
import 'package:stockflow/features/stock/low_stock_screen.dart';
import 'package:stockflow/services/notification/notification_service.dart';
import 'package:stockflow/services/store_profile_service.dart';
import 'package:stockflow/services/printer_service.dart';

// ─────────────────────────────────────────────
//  THEME CONSTANTS
// ─────────────────────────────────────────────
const _kBg = Color(0xFF0A0F1E);
const _kSurface = Color(0xFF141B2D);
const _kCard = Color(0xFF1C2539);
const _kAccent = Color(0xFF00E5A0);
const _kAccentDim = Color(0xFF00B87A);
const _kWarning = Color(0xFFFFB547);
const _kDanger = Color(0xFFFF5370);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

// ─────────────────────────────────────────────
//  MOCK PRODUCT DATABASE
// ─────────────────────────────────────────────
final Map<String, Map<String, dynamic>> _products = {
  '123456789': {
    'name': 'Rice 5kg',
    'brand': 'Golden Penny',
    'price': 14500,
    'category': 'Grains',
    'icon': '🌾',
    'stock': 48,
  },
  '987654321': {
    'name': 'Indomie Carton',
    'brand': 'Dufil Prima',
    'price': 3200,
    'category': 'Noodles',
    'icon': '🍜',
    'stock': 120,
  },
  '555555555': {
    'name': 'Peak Milk 400g Tin',
    'brand': 'FrieslandCampina',
    'price': 850,
    'category': 'Dairy',
    'icon': '🥛',
    'stock': 60,
  },
  '111222333': {
    'name': 'Dangote Sugar 1kg',
    'brand': 'Dangote',
    'price': 450,
    'category': 'Sweeteners',
    'icon': '🍬',
    'stock': 200,
  },
  '444555666': {
    'name': 'Dangote Cement 50kg',
    'brand': 'Dangote',
    'price': 3850,
    'category': 'Building Materials',
    'icon': '🏗️',
    'stock': 85,
  },
  '777888999': {
    'name': 'Sunlight Soap 800g',
    'brand': 'Unilever',
    'price': 680,
    'category': 'Cleaning',
    'icon': '🧼',
    'stock': 150,
  },
};

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    torchEnabled: false,
  );

  int _lowStockCount = 0;

  final List<Map<String, dynamic>> _cart = [];
  String _lastScanned = '';
  Map<String, dynamic>? _scannedProduct;
  String? _scannedBarcode;
  bool _flashOn = false;

  late AnimationController _productRevealController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadLowStockCount();

    _productRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnimation = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _productRevealController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _productRevealController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadLowStockCount() async {
    final count = await DatabaseHelper.instance.getLowStockCount();
    if (mounted) setState(() => _lowStockCount = count);
  }

  Future<void> _requestPermission() async {
    await Permission.camera.request();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;
      if (code == null || code == _lastScanned) continue;
      _lastScanned = code;
      HapticFeedback.mediumImpact();
      _showScannedProduct(code);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _lastScanned = '';
      });
      break;
    }
  }

  void _showScannedProduct(String barcode) {
    final product = _products[barcode];
    if (product == null) {
      HapticFeedback.heavyImpact();
      _showProductNotFound();
      return;
    }
    setState(() {
      _scannedProduct = product;
      _scannedBarcode = barcode;
    });
    _productRevealController.forward(from: 0);
  }

  void _showProductNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Product not found in database'),
          ],
        ),
        backgroundColor: _kDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addScannedToCart() {
    if (_scannedProduct == null || _scannedBarcode == null) return;
    HapticFeedback.lightImpact();

    setState(() {
      final idx = _cart.indexWhere((i) => i['barcode'] == _scannedBarcode);
      if (idx != -1) {
        _cart[idx]['quantity']++;
      } else {
        _cart.add({
          'barcode': _scannedBarcode,
          'name': _scannedProduct!['name'],
          'brand': _scannedProduct!['brand'],
          'price': _scannedProduct!['price'],
          'category': _scannedProduct!['category'],
          'icon': _scannedProduct!['icon'],
          'quantity': 1,
        });
      }
      _scannedProduct = null;
      _scannedBarcode = null;
    });
    _productRevealController.reverse();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Added to cart'),
          ],
        ),
        backgroundColor: _kAccentDim,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _dismissScanned() {
    setState(() {
      _scannedProduct = null;
      _scannedBarcode = null;
    });
    _productRevealController.reverse();
  }

  void _removeFromCart(int index) {
    HapticFeedback.lightImpact();
    setState(() => _cart.removeAt(index));
  }

  double get _total => _cart.fold(
    0.0,
    (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
  );

  int get _totalItems =>
      _cart.fold(0, (sum, item) => sum + (item['quantity'] as int));

  void _completeSale() async {
    if (_cart.isEmpty) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                ReceiptScreen(cart: List.from(_cart), total: _total),
          ),
        )
        .then((_) {
          setState(() => _cart.clear());
        });

    await NotificationService.instance.checkAndNotifyLowStock();
    _loadLowStockCount();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _productRevealController.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _kBg,
        colorScheme: const ColorScheme.dark(
          primary: _kAccent,
          surface: _kSurface,
        ),
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildScannerSection(),
              if (_scannedProduct != null) _buildProductReveal(),
              _buildCartSection(),
              _buildCheckoutBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: _kAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SCAN & PAY',
                style: TextStyle(
                  color: _kText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '$_totalItems item${_totalItems == 1 ? '' : 's'} in cart',
                style: const TextStyle(color: _kTextDim, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          _headerIcon(
            icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            color: _flashOn ? _kWarning : _kTextDim,
            onTap: () {
              setState(() => _flashOn = !_flashOn);
              _scannerController.toggleTorch();
            },
          ),
          _headerIcon(
            icon: Icons.history_rounded,
            color: _kTextDim,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
              );
            },
          ),

          // _headerIcon(
          //   icon: Icons.label_rounded,
          //   color: _kTextDim,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const BarcodeLabelsScreen()),
          //     );
          //   },
          // ),

          // _headerIcon(
          //   icon: Icons.bar_chart_rounded,
          //   color: _kTextDim,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const ReportsScreen()),
          //     );
          //   },
          // ),
          _badgeIcon(
            icon: Icons.warning_amber_rounded,
            color: _lowStockCount > 0 ? _kWarning : _kTextDim,
            badge: _lowStockCount,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LowStockScreen()),
              );
              _loadLowStockCount(); // refresh badge on return
            },
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _badgeIcon({
    required IconData icon,
    required Color color,
    required int badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, color: color, size: 20)),
            if (badge > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    color: _kWarning,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── SCANNER ──────────────────────────────────
  Widget _buildScannerSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5),
        child: Stack(
          children: [
            MobileScanner(controller: _scannerController, onDetect: _onDetect),
            // Corner decorations
            ..._buildScanCorners(),
            // Scan line animation
            const _ScanLine(),
            // Bottom label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
                child: const Text(
                  '⬛  Point at barcode or QR code to scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScanCorners() {
    const size = 22.0;
    const thick = 3.0;
    const color = _kAccent;
    final corners = [
      [Alignment.topLeft, BorderRadius.only(topLeft: Radius.circular(4))],
      [Alignment.topRight, BorderRadius.only(topRight: Radius.circular(4))],
      [Alignment.bottomLeft, BorderRadius.only(bottomLeft: Radius.circular(4))],
      [
        Alignment.bottomRight,
        BorderRadius.only(bottomRight: Radius.circular(4)),
      ],
    ];

    return corners.map((c) {
      final align = c[0] as Alignment;
      return Positioned(
        top: align.y < 0 ? 12 : null,
        bottom: align.y > 0 ? 12 : null,
        left: align.x < 0 ? 12 : null,
        right: align.x > 0 ? 12 : null,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CornerPainter(
              isTop: align.y < 0,
              isLeft: align.x < 0,
              color: color,
              thickness: thick,
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── PRODUCT REVEAL ───────────────────────────
  Widget _buildProductReveal() {
    return AnimatedBuilder(
      animation: _productRevealController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kAccent.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  _scannedProduct?['icon'] ?? '📦',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scannedProduct?['name'] ?? '',
                    style: const TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_scannedProduct?['brand']} · ${_scannedProduct?['category']}',
                    style: const TextStyle(color: _kTextDim, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₦${_formatPrice(_scannedProduct?['price'] ?? 0)}',
                        style: const TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _kAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_scannedProduct?['stock']} in stock',
                          style: const TextStyle(color: _kAccent, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                GestureDetector(
                  onTap: _addScannedToCart,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _kAccent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: _kBg,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _dismissScanned,
                  child: Container(
                    width: 46,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kDanger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: _kDanger,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── CART LIST ────────────────────────────────
  Widget _buildCartSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cart',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (_cart.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() => _cart.clear());
                    },
                    child: const Text(
                      'Clear all',
                      style: TextStyle(color: _kDanger, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _cart.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cart.length,
                    itemBuilder: (ctx, i) => _buildCartItem(i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: _kSurface, shape: BoxShape.circle),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: _kTextDim,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items yet',
            style: TextStyle(
              color: _kText,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Scan a product barcode above\nto add it to the cart',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kTextDim, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cart[index];
    final subtotal = (item['price'] as int) * (item['quantity'] as int);

    return Dismissible(
      key: Key(item['barcode']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeFromCart(index),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _kDanger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: _kDanger),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Text(item['icon'] ?? '📦', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '₦${_formatPrice(item['price'])} each',
                    style: const TextStyle(color: _kTextDim, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${_formatPrice(subtotal)}',
                  style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                _quantityControl(index, item),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityControl(int index, Map<String, dynamic> item) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            icon: Icons.remove,
            onTap: () {
              setState(() {
                if (item['quantity'] > 1) {
                  item['quantity']--;
                } else {
                  _cart.removeAt(index);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${item['quantity']}',
              style: const TextStyle(
                color: _kText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          _qtyBtn(
            icon: Icons.add,
            onTap: () => setState(() => item['quantity']++),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(icon, size: 14, color: _kTextDim),
      ),
    );
  }

  // ── CHECKOUT BAR ─────────────────────────────
  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: _kTextDim,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₦${_formatPrice(_total.toInt())}',
                style: const TextStyle(
                  color: _kText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _cart.isEmpty ? null : _completeSale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  color: _cart.isEmpty ? _kAccent.withOpacity(0.25) : _kAccent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _cart.isEmpty
                      ? []
                      : [
                          BoxShadow(
                            color: _kAccent.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: _cart.isEmpty ? _kBg.withOpacity(0.4) : _kBg,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generate Receipt',
                      style: TextStyle(
                        color: _cart.isEmpty ? _kBg.withOpacity(0.4) : _kBg,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
//  SCAN LINE ANIMATION
// ─────────────────────────────────────────────
class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.05,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0, // relative to Stack
          left: 0,
          right: 0,
          child: FractionalTranslation(
            translation: Offset(0, _anim.value * 9.5),
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kAccent.withOpacity(0.8),
                    _kAccent,
                    _kAccent.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kAccent.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  CORNER PAINTER
// ─────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;
  final double thickness;

  const _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class ReceiptScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final double total;

  const ReceiptScreen({super.key, required this.cart, required this.total});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _slide;

  final String _receiptNo =
      'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  final DateTime _now = DateTime.now();

  bool _saleSaved = false;
  String _storeName = 'My Store';
  String _storeAddress = '';
  String _storePhone = '';
  String _footer = 'Thank you for your purchase!';

  // ── Single initState — no duplicates ──────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _saveSale();
    _loadStoreProfile();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Load store profile from SharedPreferences ─────────────────────────────
  Future<void> _loadStoreProfile() async {
    final profile = await StoreProfileService.instance.load();
    if (!mounted) return;
    setState(() {
      _storeName = profile.name;
      _storeAddress = profile.address;
      _storePhone = profile.phone;
      _footer = profile.footer;
    });
  }

  // ── Save sale to DB (once only) ───────────────────────────────────────────
  Future<void> _saveSale() async {
    if (_saleSaved) return;
    _saleSaved = true;

    final subtotal = widget.total;
    final vat = subtotal * 0.075;
    final total = subtotal + vat;

    await DatabaseHelper.instance.insertSale(
      receiptNo: _receiptNo,
      subtotal: subtotal,
      vat: vat,
      total: total,
      items: widget.cart,
    );
  }

  // ── Print receipt ─────────────────────────────────────────────────────────
  Future<void> _printReceipt() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrinterSheet(
        storeName: _storeName,
        storeAddress: _storeAddress,
        storePhone: _storePhone,
        receiptNo: _receiptNo,
        soldAt: _now,
        items: widget.cart,
        subtotal: widget.total,
        vat: widget.total * 0.075,
        total: widget.total * 1.075,
        footer: _footer,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatPrice(num price) {
    final p = price.toInt();
    if (p >= 1000) {
      final s = p.toString();
      final result = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result.write(',');
        result.write(s[i]);
        count++;
      }
      return result.toString().split('').reversed.join();
    }
    return p.toString();
  }

  String get _formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = _now.hour > 12
        ? _now.hour - 12
        : (_now.hour == 0 ? 12 : _now.hour);
    final m = _now.minute.toString().padLeft(2, '0');
    final ampm = _now.hour >= 12 ? 'PM' : 'AM';
    return '${_now.day} ${months[_now.month - 1]} ${_now.year}  •  $h:$m $ampm';
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
            'Receipt',
            style: TextStyle(
              color: _kText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: _kTextDim),
              onPressed: _printReceipt,
            ),
            // IconButton(
            //   icon: const Icon(Icons.print_rounded, color: _kTextDim),
            //   onPressed: _printReceipt,
            // ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: child,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [_buildReceiptCard()]),
                ),
              ),
              _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Store Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(color: _kAccent.withOpacity(0.15)),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: _kAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'MY STORE',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Official Sales Receipt',
                  style: TextStyle(color: _kTextDim, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _receiptMeta('Receipt No.', _receiptNo),
                    _receiptMeta(
                      'Date & Time',
                      _formattedDate,
                      align: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                // Header row
                Row(
                  children: const [
                    Expanded(
                      flex: 5,
                      child: Text(
                        'ITEM',
                        style: TextStyle(
                          color: _kTextDim,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      'QTY',
                      style: TextStyle(
                        color: _kTextDim,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'AMOUNT',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: _kTextDim,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),

                // Items list
                ...widget.cart.map((item) {
                  final subtotal =
                      (item['price'] as int) * (item['quantity'] as int);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item['icon']}  ${item['name']}',
                                style: const TextStyle(
                                  color: _kText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '₦${_formatPrice(item['price'])} each',
                                style: const TextStyle(
                                  color: _kTextDim,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'x${item['quantity']}',
                          style: const TextStyle(
                            color: _kTextDim,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          child: Text(
                            '₦${_formatPrice(subtotal)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: _kText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Totals
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _totalRow('Subtotal', '₦${_formatPrice(widget.total)}'),
                const SizedBox(height: 8),
                _totalRow(
                  'VAT (7.5%)',
                  '₦${_formatPrice(widget.total * 0.075)}',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.white12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL PAID',
                      style: TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₦${_formatPrice(widget.total * 1.075)}',
                      style: const TextStyle(
                        color: _kAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _kAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sale Completed Successfully',
                        style: TextStyle(
                          color: _kAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank you for your purchase!\nPlease come again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kTextDim, fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Wrong

  Widget _receiptMeta(
    String label,
    String value, {
    TextAlign align = TextAlign.left,
  }) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _kTextDim, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: _kText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _kTextDim, fontSize: 13)),
        Text(value, style: const TextStyle(color: _kText, fontSize: 13)),
      ],
    );
  }

  Widget _buildDoneButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: _kBg,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: _kBg, size: 20),
              SizedBox(width: 10),
              Text(
                'Scan New Transaction',
                style: TextStyle(
                  color: _kBg,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PRINTER SHEET
//  Paste this at the bottom of pos_screen.dart,
//  AFTER the closing } of _ReceiptScreenState.
// ─────────────────────────────────────────────
class _PrinterSheet extends StatefulWidget {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String receiptNo;
  final DateTime soldAt;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double vat;
  final double total;
  final String footer;

  const _PrinterSheet({
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.receiptNo,
    required this.soldAt,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.footer,
  });

  @override
  State<_PrinterSheet> createState() => _PrinterSheetState();
}

class _PrinterSheetState extends State<_PrinterSheet> {
  bool _printing = false;
  String _status = '';

  Future<void> _print() async {
    setState(() {
      _printing = true;
      _status = 'Opening print dialog…';
    });
    try {
      await PrinterService.instance.printReceipt(
        context: context,
        storeName: widget.storeName,
        storeAddress: widget.storeAddress,
        storePhone: widget.storePhone,
        receiptNo: widget.receiptNo,
        soldAt: widget.soldAt,
        items: widget.items,
        subtotal: widget.subtotal,
        vat: widget.vat,
        total: widget.total,
        footer: widget.footer,
      );
      if (mounted)
        setState(() {
          _printing = false;
          _status = '';
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _printing = false;
          _status = 'Print failed: $e';
        });
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _printing = true;
      _status = 'Generating PDF…';
    });
    try {
      await PrinterService.instance.shareReceiptAsPdf(
        storeName: widget.storeName,
        storeAddress: widget.storeAddress,
        storePhone: widget.storePhone,
        receiptNo: widget.receiptNo,
        soldAt: widget.soldAt,
        items: widget.items,
        subtotal: widget.subtotal,
        vat: widget.vat,
        total: widget.total,
        footer: widget.footer,
      );
      if (mounted)
        setState(() {
          _printing = false;
          _status = '';
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _printing = false;
          _status = 'Share failed: $e';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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

          // Title row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.print_rounded,
                  color: Color(0xFF0066FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Print Receipt',
                      style: TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.receiptNo,
                      style: const TextStyle(color: _kTextDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (_printing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kAccent,
                      ),
                    )
                  else
                    Icon(
                      _status.contains('failed')
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: _status.contains('failed') ? _kDanger : _kAccent,
                      size: 14,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('failed') ? _kDanger : _kAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Option 1 — Print
          _optionTile(
            icon: Icons.print_rounded,
            color: const Color(0xFF0066FF),
            title: 'Print to Bluetooth / WiFi Printer',
            subtitle: 'Opens system print dialog. Select your thermal printer.',
            onTap: _printing ? null : _print,
          ),
          const SizedBox(height: 10),

          // Option 2 — Share PDF
          _optionTile(
            icon: Icons.picture_as_pdf_rounded,
            color: _kAccent,
            title: 'Share / Save as PDF',
            subtitle: 'Send via WhatsApp, email or save to phone.',
            onTap: _printing ? null : _sharePdf,
          ),
          const SizedBox(height: 20),

          // Cancel
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _kTextDim, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _kTextDim,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
