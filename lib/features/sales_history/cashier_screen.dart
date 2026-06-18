// // lib/screens/cashier_home_screen.dart
// //
// // Home screen shown to cashiers (non-owners) after login.
// // Limited to: POS, their own sales history, and logout.

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:stockflow/database/database_helper.dart';
// import 'package:stockflow/features/auth/seller_login_screen.dart';
// import 'package:stockflow/features/posscreen/posscreen.dart';
// import 'package:stockflow/models/seller.dart';
// import 'package:stockflow/services/seller_session.dart';

// const _kBg = Color(0xFFF0F4F8);
// const _kWhite = Colors.white;
// const _kBlue = Color(0xFF0057FF);
// const _kGreen = Color(0xFF00C17C);
// const _kOrange = Color(0xFFFF8C00);
// const _kRed = Color(0xFFE53935);
// const _kInk = Color(0xFF0D1B2A);
// const _kInkMid = Color(0xFF4A5568);
// const _kInkSoft = Color(0xFFCBD5E0);
// const _kBorder = Color(0xFFEEF2F7);

// class CashierHomeScreen extends StatefulWidget {
//   const CashierHomeScreen({super.key});

//   @override
//   State<CashierHomeScreen> createState() => _CashierHomeScreenState();
// }

// class _CashierHomeScreenState extends State<CashierHomeScreen> {
//   final _db = DatabaseHelper.instance;
//   final _fmt = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

//   bool _loading = true;
//   Map<String, dynamic> _todaySummary = {};
//   List<Map<String, dynamic>> _recentSales = [];

//   Seller get _seller => SellerSession.instance.current!;

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _loading = true);
//     try {
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);

//       final summary = await _db.getSellerSummary(
//         _seller.id!,
//         from: today,
//         to: now,
//       );
//       final sales = await _db.getSalesBySeller(
//         _seller.id!,
//         from: today,
//         to: now,
//       );

//       setState(() {
//         _todaySummary = summary;
//         _recentSales = sales.take(5).toList();
//         _loading = false;
//       });
//     } catch (e) {
//       debugPrint('CashierHome error: $e');
//       setState(() => _loading = false);
//     }
//   }

//   double _toDouble(dynamic v) => ((v ?? 0) as num).toDouble();

//   // ── Logout ─────────────────────────────────────────────────────────────────
//   Future<void> _logout() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         title: const Text(
//           'Log Out',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         content: const Text(
//           'End your session and return to the seller screen?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text(
//               'Log Out',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       SellerSession.instance.logout();
//       if (!mounted) return;
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const SellerLoginScreen()),
//         (_) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final initials = _seller.name
//         .trim()
//         .split(' ')
//         .take(2)
//         .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
//         .join();

//     return Scaffold(
//       backgroundColor: _kBg,
//       appBar: AppBar(
//         backgroundColor: _kWhite,
//         elevation: 0,
//         surfaceTintColor: _kWhite,
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: _kBlue,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.storefront_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'StockFlow',
//               style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 18,
//                 color: _kInk,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout_rounded, color: _kRed),
//             onPressed: _logout,
//             tooltip: 'Log out',
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator(color: _kBlue))
//           : RefreshIndicator(
//               onRefresh: _load,
//               color: _kBlue,
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   // ── Greeting ──────────────────────────────────────────
//                   _buildGreeting(initials),
//                   const SizedBox(height: 20),

//                   // ── Today's stats ──────────────────────────────────────
//                   _buildTodayStats(),
//                   const SizedBox(height: 20),

//                   // ── Main action — POS ──────────────────────────────────
//                   _buildScanButton(),
//                   const SizedBox(height: 20),

//                   // ── Recent sales ───────────────────────────────────────
//                   _buildRecentSales(),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//     );
//   }

//   // ── Greeting card ──────────────────────────────────────────────────────────
//   Widget _buildGreeting(String initials) {
//     final h = DateTime.now().hour;
//     final greeting = h < 12
//         ? 'Good morning'
//         : h < 17
//         ? 'Good afternoon'
//         : 'Good evening';

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF0044DD), Color(0xFF0099FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: _kBlue.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 initials,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$greeting!',
//                   style: const TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//                 Text(
//                   _seller.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.only(top: 4),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: const Text(
//                     'Cashier',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Today's stats ──────────────────────────────────────────────────────────
//   Widget _buildTodayStats() {
//     final revenue = _toDouble(_todaySummary['total_revenue']);
//     final orders = (_todaySummary['transaction_count'] ?? 0) as int;
//     final items = (_todaySummary['total_items_sold'] ?? 0) as int;

//     return Row(
//       children: [
//         _statCard(
//           'Revenue Today',
//           _fmt.format(revenue),
//           Icons.payments_rounded,
//           _kBlue,
//         ),
//         const SizedBox(width: 10),
//         _statCard('Sales', '$orders', Icons.receipt_long_rounded, _kGreen),
//         const SizedBox(width: 10),
//         _statCard('Items', '$items', Icons.shopping_bag_rounded, _kOrange),
//       ],
//     );
//   }

//   Widget _statCard(String label, String value, IconData icon, Color color) =>
//       Expanded(
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: _kWhite,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(icon, color: color, size: 18),
//               const SizedBox(height: 8),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 14,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 label,
//                 style: const TextStyle(color: _kInkMid, fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//       );

//   // ── Big scan button ────────────────────────────────────────────────────────
//   Widget _buildScanButton() => GestureDetector(
//     onTap: () => Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const PosScreen()),
//     ).then((_) => _load()),
//     child: Container(
//       width: double.infinity,
//       height: 100,
//       decoration: BoxDecoration(
//         color: _kGreen,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: _kGreen.withOpacity(0.35),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 40),
//           SizedBox(width: 16),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Scan & Sell',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               Text(
//                 'Tap to open POS scanner',
//                 style: TextStyle(color: Colors.white70, fontSize: 13),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );

//   // ── Recent sales list ──────────────────────────────────────────────────────
//   Widget _buildRecentSales() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _kWhite,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Today's Sales",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15,
//                   color: _kInk,
//                 ),
//               ),
//               Text(
//                 '${(_todaySummary['transaction_count'] ?? 0)} total',
//                 style: const TextStyle(color: _kInkMid, fontSize: 12),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (_recentSales.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Center(
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.receipt_long_outlined,
//                       color: _kInkSoft,
//                       size: 40,
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'No sales yet today',
//                       style: TextStyle(color: _kInkMid, fontSize: 13),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       'Tap Scan & Sell to start',
//                       style: TextStyle(color: _kInkSoft, fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             ...(_recentSales.map((sale) {
//               final total = _toDouble(sale['total']);
//               final dt = DateTime.parse(sale['sold_at'] as String);
//               final h = dt.hour > 12
//                   ? dt.hour - 12
//                   : (dt.hour == 0 ? 12 : dt.hour);
//               final m = dt.minute.toString().padLeft(2, '0');
//               final ampm = dt.hour >= 12 ? 'PM' : 'AM';

//               return Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: _kBg,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: _kBorder),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 38,
//                       height: 38,
//                       decoration: BoxDecoration(
//                         color: _kBlue.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Icon(
//                         Icons.receipt_rounded,
//                         color: _kBlue,
//                         size: 18,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             sale['receipt_no'] as String,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13,
//                               color: _kInk,
//                             ),
//                           ),
//                           Text(
//                             '${sale['item_count']} item${(sale['item_count'] as int) == 1 ? '' : 's'}  ·  $h:$m $ampm',
//                             style: const TextStyle(
//                               color: _kInkMid,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       _fmt.format(total),
//                       style: const TextStyle(
//                         color: _kGreen,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             })),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/cashier_home_screen.dart
//
// Home screen shown to cashiers (non-owners) after login.
// Limited to: POS, their own sales history, and logout.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/auth/seller_login_screen.dart';
import 'package:stockflow/features/posscreen/posscreen.dart';
import 'package:stockflow/models/seller.dart';
import 'package:stockflow/services/seller_session.dart';

const _kBg = Color(0xFFF0F4F8);
const _kWhite = Colors.white;
const _kBlue = Color(0xFF0057FF);
const _kGreen = Color(0xFF00C17C);
const _kOrange = Color(0xFFFF8C00);
const _kRed = Color(0xFFE53935);
const _kInk = Color(0xFF0D1B2A);
const _kInkMid = Color(0xFF4A5568);
const _kInkSoft = Color(0xFFCBD5E0);
const _kBorder = Color(0xFFEEF2F7);

class CashierHomeScreen extends StatefulWidget {
  const CashierHomeScreen({super.key});

  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  final _db = DatabaseHelper.instance;
  final _fmt = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  bool _loading = true;
  Map<String, dynamic> _todaySummary = {};
  List<Map<String, dynamic>> _recentSales = [];

  Seller get _seller => SellerSession.instance.current!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final summary = await _db.getSellerSummary(
        _seller.id!,
        from: today,
        to: now,
      );
      final sales = await _db.getSalesBySeller(
        _seller.id!,
        from: today,
        to: now,
      );

      setState(() {
        _todaySummary = summary;
        _recentSales = sales.take(5).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('CashierHome error: $e');
      setState(() => _loading = false);
    }
  }

  double _toDouble(dynamic v) => ((v ?? 0) as num).toDouble();

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'End your session and return to the seller screen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      SellerSession.instance.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SellerLoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _seller.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        surfaceTintColor: _kWhite,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _kBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'StockFlow',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: _kInk,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: _kRed),
            onPressed: _logout,
            tooltip: 'Log out',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kBlue))
          : RefreshIndicator(
              onRefresh: _load,
              color: _kBlue,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Greeting ──────────────────────────────────────────
                  _buildGreeting(initials),
                  const SizedBox(height: 20),

                  // ── Today's stats ──────────────────────────────────────
                  _buildTodayStats(),
                  const SizedBox(height: 20),

                  // ── Main action — POS ──────────────────────────────────
                  _buildScanButton(),
                  const SizedBox(height: 20),

                  // ── Recent sales ───────────────────────────────────────
                  _buildRecentSales(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ── Greeting card ──────────────────────────────────────────────────────────
  Widget _buildGreeting(String initials) {
    final h = DateTime.now().hour;
    final greeting = h < 12
        ? 'Good morning'
        : h < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0044DD), Color(0xFF0099FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting!',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  _seller.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Cashier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's stats ──────────────────────────────────────────────────────────
  Widget _buildTodayStats() {
    final revenue = _toDouble(_todaySummary['total_revenue']);
    final orders = (_todaySummary['transaction_count'] ?? 0) as int;
    final items = (_todaySummary['total_items_sold'] ?? 0) as int;

    return Row(
      children: [
        _statCard(
          'Revenue Today',
          _fmt.format(revenue),
          Icons.payments_rounded,
          _kBlue,
        ),
        const SizedBox(width: 10),
        _statCard('Sales', '$orders', Icons.receipt_long_rounded, _kGreen),
        const SizedBox(width: 10),
        _statCard('Items', '$items', Icons.shopping_bag_rounded, _kOrange),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(16),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(color: _kInkMid, fontSize: 10),
              ),
            ],
          ),
        ),
      );

  // ── Big scan button ────────────────────────────────────────────────────────
  Widget _buildScanButton() => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PosScreen()),
    ).then((_) => _load()),
    child: Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan & Sell',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Tap to open POS scanner',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // ── Recent sales list ──────────────────────────────────────────────────────
  Widget _buildRecentSales() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Sales",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _kInk,
                ),
              ),
              Text(
                '${(_todaySummary['transaction_count'] ?? 0)} total',
                style: const TextStyle(color: _kInkMid, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentSales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: _kInkSoft,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No sales yet today',
                      style: TextStyle(color: _kInkMid, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap Scan & Sell to start',
                      style: TextStyle(color: _kInkSoft, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_recentSales.map((sale) {
              final total = _toDouble(sale['total']);
              final dt = DateTime.parse(sale['sold_at'] as String);
              final h = dt.hour > 12
                  ? dt.hour - 12
                  : (dt.hour == 0 ? 12 : dt.hour);
              final m = dt.minute.toString().padLeft(2, '0');
              final ampm = dt.hour >= 12 ? 'PM' : 'AM';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _kBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_rounded,
                        color: _kBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale['receipt_no'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _kInk,
                            ),
                          ),
                          Text(
                            '${sale['item_count']} item${(sale['item_count'] as int) == 1 ? '' : 's'}  ·  $h:$m $ampm',
                            style: const TextStyle(
                              color: _kInkMid,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _fmt.format(total),
                      style: const TextStyle(
                        color: _kGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            })),
        ],
      ),
    );
  }
}
