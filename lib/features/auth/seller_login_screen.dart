// // lib/screens/seller_login_screen.dart
// //
// // Shown before the POS screen.
// // Cashier taps their name → enters 4-digit PIN → enters POS.
// // Owner can also bypass with the master passcode.

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:stockflow/database/database_helper.dart';
// import 'package:stockflow/features/dashboard/ashboard_screen.dart';
// import 'package:stockflow/features/posscreen/posscreen.dart';
// import 'package:stockflow/features/sales_history/cashier_screen.dart';
// import 'package:stockflow/models/seller.dart';
// import 'package:stockflow/services/seller_session.dart';

// const _kBg = Color(0xFF0A0F1E);
// const _kCard = Color(0xFF1C2539);
// const _kSurface = Color(0xFF141B2D);
// const _kAccent = Color(0xFF0066FF);
// const _kGreen = Color(0xFF00E5A0);
// const _kDanger = Color(0xFFFF5370);
// const _kText = Color(0xFFEEF2FF);
// const _kTextDim = Color(0xFF8892A4);

// class SellerLoginScreen extends StatefulWidget {
//   const SellerLoginScreen({super.key});

//   @override
//   State<SellerLoginScreen> createState() => _SellerLoginScreenState();
// }

// class _SellerLoginScreenState extends State<SellerLoginScreen> {
//   final _db = DatabaseHelper.instance;

//   List<Seller> _sellers = [];
//   Seller? _selected;
//   String _pin = '';
//   String _error = '';
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadSellers();
//   }

//   Future<void> _loadSellers() async {
//     final rows = await _db.getAllSellers();
//     setState(() {
//       _sellers = rows.map(Seller.fromMap).toList();
//       _loading = false;
//     });
//   }

//   void _selectSeller(Seller s) {
//     setState(() {
//       _selected = s;
//       _pin = '';
//       _error = '';
//     });
//   }

//   void _onKey(String k) {
//     if (_pin.length >= 4) return;
//     HapticFeedback.lightImpact();
//     setState(() {
//       _pin += k;
//       _error = '';
//     });
//     if (_pin.length == 4) _verify();
//   }

//   void _onDelete() {
//     if (_pin.isEmpty) return;
//     HapticFeedback.lightImpact();
//     setState(() => _pin = _pin.substring(0, _pin.length - 1));
//   }

//   // Future<void> _verify() async {
//   //   if (_selected == null) return;
//   //   if (_pin == _selected!.pin) {
//   //     SellerSession.instance.login(_selected!);
//   //     if (!mounted) return;
//   //     Navigator.pushReplacement(
//   //       context,
//   //       MaterialPageRoute(builder: (_) => const PosScreen()),
//   //     );
//   //   } else {
//   //     HapticFeedback.heavyImpact();
//   //     setState(() {
//   //       _error = 'Wrong PIN. Try again.';
//   //       _pin = '';
//   //     });
//   //   }
//   // }

//   Future<void> _verify() async {
//     if (_selected == null) return;
//     if (_pin == _selected!.pin) {
//       SellerSession.instance.login(_selected!);
//       if (!mounted) return;

//       // ✅ Route based on role
//       if (_selected!.isOwner) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const DashboardScreen()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const CashierHomeScreen()),
//         );
//       }
//     } else {
//       HapticFeedback.heavyImpact();
//       setState(() {
//         _error = 'Wrong PIN. Try again.';
//         _pin = '';
//       });
//     }
//   }

//   void _back() => setState(() {
//     _selected = null;
//     _pin = '';
//     _error = '';
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _kBg),
//       child: Scaffold(
//         backgroundColor: _kBg,
//         body: SafeArea(
//           child: _loading
//               ? const Center(child: CircularProgressIndicator(color: _kAccent))
//               : _selected == null
//               ? _buildSellerPicker()
//               : _buildPinEntry(),
//         ),
//       ),
//     );
//   }

//   // ── Seller picker ──────────────────────────────────────────────────────────
//   Widget _buildSellerPicker() {
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         // Logo
//         Container(
//           width: 64,
//           height: 64,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF0044DD), Color(0xFF0099FF)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: const Icon(
//             Icons.storefront_rounded,
//             color: Colors.white,
//             size: 32,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Who is selling today?',
//           style: TextStyle(
//             color: _kText,
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           'Select your name to continue',
//           style: TextStyle(color: _kTextDim, fontSize: 14),
//         ),
//         const SizedBox(height: 32),

//         if (_sellers.isEmpty)
//           _buildNoSellers()
//         else
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 14,
//                 mainAxisSpacing: 14,
//                 childAspectRatio: 1.2,
//               ),
//               itemCount: _sellers.length,
//               itemBuilder: (_, i) => _sellerCard(_sellers[i]),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _sellerCard(Seller s) {
//     final colors = [
//       _kAccent,
//       _kGreen,
//       const Color(0xFFFFB547),
//       const Color(0xFFFF85A2),
//       const Color(0xFF7C9FFF),
//       const Color(0xFFB47FFF),
//     ];
//     final idx = _sellers.indexOf(s) % colors.length;
//     final color = colors[idx];
//     final initials = s.name
//         .trim()
//         .split(' ')
//         .take(2)
//         .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
//         .join();

//     return GestureDetector(
//       onTap: () => _selectSeller(s),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _kCard,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   initials,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               s.name,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: _kText,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 s.isOwner ? 'Owner' : 'Cashier',
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoSellers() => Expanded(
//     child: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.group_off_rounded, color: _kTextDim, size: 56),
//           const SizedBox(height: 16),
//           const Text(
//             'No sellers added yet',
//             style: TextStyle(
//               color: _kText,
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Go to Settings → Sellers\nto add cashiers',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: _kTextDim, fontSize: 13, height: 1.5),
//           ),
//           const SizedBox(height: 24),
//           // Still allow owner to proceed without sellers
//           GestureDetector(
//             onTap: () {
//               SellerSession.instance.logout();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => const PosScreen()),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 color: _kAccent,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Text(
//                 'Continue as Owner',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );

//   // ── PIN entry ──────────────────────────────────────────────────────────────
//   Widget _buildPinEntry() {
//     return Column(
//       children: [
//         const SizedBox(height: 32),
//         // Back
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: GestureDetector(
//               onTap: _back,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _kCard,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       color: _kTextDim,
//                       size: 14,
//                     ),
//                     SizedBox(width: 4),
//                     Text(
//                       'Back',
//                       style: TextStyle(color: _kTextDim, fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 32),

//         // Avatar
//         _buildAvatar(_selected!),
//         const SizedBox(height: 12),
//         Text(
//           _selected!.name,
//           style: const TextStyle(
//             color: _kText,
//             fontSize: 20,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           _selected!.isOwner ? 'Owner' : 'Cashier',
//           style: const TextStyle(color: _kTextDim, fontSize: 13),
//         ),
//         const SizedBox(height: 32),

//         // Dots
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(4, (i) {
//             final filled = i < _pin.length;
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 150),
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               width: 18,
//               height: 18,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: filled ? _kAccent : Colors.transparent,
//                 border: Border.all(
//                   color: filled ? _kAccent : _kTextDim,
//                   width: 2,
//                 ),
//               ),
//             );
//           }),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           _error.isEmpty ? 'Enter your PIN' : _error,
//           style: TextStyle(
//             color: _error.isEmpty ? _kTextDim : _kDanger,
//             fontSize: 13,
//           ),
//         ),

//         const Spacer(),

//         // Keypad
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 48),
//           child: Column(
//             children: [
//               ...[
//                 ['1', '2', '3'],
//                 ['4', '5', '6'],
//                 ['7', '8', '9'],
//                 ['', '0', 'del'],
//               ].map(
//                 (row) => Padding(
//                   padding: const EdgeInsets.only(bottom: 14),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: row.map((k) {
//                       if (k.isEmpty) {
//                         return const SizedBox(width: 72, height: 72);
//                       }
//                       return GestureDetector(
//                         onTap: k == 'del' ? _onDelete : () => _onKey(k),
//                         child: Container(
//                           width: 72,
//                           height: 72,
//                           decoration: BoxDecoration(
//                             color: _kCard,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: k == 'del'
//                                 ? const Icon(
//                                     Icons.backspace_outlined,
//                                     color: _kTextDim,
//                                     size: 22,
//                                   )
//                                 : Text(
//                                     k,
//                                     style: const TextStyle(
//                                       color: _kText,
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget _buildAvatar(Seller s) {
//     final colors = [
//       _kAccent,
//       _kGreen,
//       const Color(0xFFFFB547),
//       const Color(0xFFFF85A2),
//     ];
//     final color = colors[_sellers.indexOf(s) % colors.length];
//     final initials = s.name
//         .trim()
//         .split(' ')
//         .take(2)
//         .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
//         .join();
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         shape: BoxShape.circle,
//         border: Border.all(color: color.withOpacity(0.4), width: 2),
//       ),
//       child: Center(
//         child: Text(
//           initials,
//           style: TextStyle(
//             color: color,
//             fontSize: 28,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/seller_login_screen.dart
//
// Shown before the POS screen.
// Cashier taps their name → enters 4-digit PIN → enters POS.
// Owner can also bypass with the master passcode.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/database/database_helper.dart';
import 'package:stockflow/features/dashboard/ashboard_screen.dart';
import 'package:stockflow/features/posscreen/posscreen.dart';
import 'package:stockflow/features/sales_history/cashier_screen.dart';
import 'package:stockflow/models/seller.dart';
import 'package:stockflow/services/seller_session.dart';

const _kBg = Color(0xFF0A0F1E);
const _kCard = Color(0xFF1C2539);
const _kSurface = Color(0xFF141B2D);
const _kAccent = Color(0xFF0066FF);
const _kGreen = Color(0xFF00E5A0);
const _kDanger = Color(0xFFFF5370);
const _kText = Color(0xFFEEF2FF);
const _kTextDim = Color(0xFF8892A4);

class SellerLoginScreen extends StatefulWidget {
  const SellerLoginScreen({super.key});

  @override
  State<SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends State<SellerLoginScreen> {
  final _db = DatabaseHelper.instance;

  List<Seller> _sellers = [];
  Seller? _selected;
  String _pin = '';
  String _error = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    final rows = await _db.getAllSellers();
    setState(() {
      _sellers = rows.map(Seller.fromMap).toList();
      _loading = false;
    });
  }

  void _selectSeller(Seller s) {
    setState(() {
      _selected = s;
      _pin = '';
      _error = '';
    });
  }

  void _onKey(String k) {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += k;
      _error = '';
    });
    if (_pin.length == 4) _verify();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  // Future<void> _verify() async {
  //   if (_selected == null) return;
  //   if (_pin == _selected!.pin) {
  //     SellerSession.instance.login(_selected!);
  //     if (!mounted) return;
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const PosScreen()),
  //     );
  //   } else {
  //     HapticFeedback.heavyImpact();
  //     setState(() {
  //       _error = 'Wrong PIN. Try again.';
  //       _pin = '';
  //     });
  //   }
  // }

  Future<void> _verify() async {
    if (_selected == null) return;
    if (_pin == _selected!.pin) {
      SellerSession.instance.login(_selected!);
      if (!mounted) return;

      // ✅ Route based on role
      if (_selected!.isOwner) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CashierHomeScreen()),
        );
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'Wrong PIN. Try again.';
        _pin = '';
      });
    }
  }

  void _back() => setState(() {
    _selected = null;
    _pin = '';
    _error = '';
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _kBg),
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _kAccent))
              : _selected == null
              ? _buildSellerPicker()
              : _buildPinEntry(),
        ),
      ),
    );
  }

  // ── Seller picker ──────────────────────────────────────────────────────────
  Widget _buildSellerPicker() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0044DD), Color(0xFF0099FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Who is selling today?',
          style: TextStyle(
            color: _kText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your name to continue',
          style: TextStyle(color: _kTextDim, fontSize: 14),
        ),
        const SizedBox(height: 32),

        if (_sellers.isEmpty)
          _buildNoSellers()
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.2,
              ),
              itemCount: _sellers.length,
              itemBuilder: (_, i) => _sellerCard(_sellers[i]),
            ),
          ),
      ],
    );
  }

  Widget _sellerCard(Seller s) {
    final colors = [
      _kAccent,
      _kGreen,
      const Color(0xFFFFB547),
      const Color(0xFFFF85A2),
      const Color(0xFF7C9FFF),
      const Color(0xFFB47FFF),
    ];
    final idx = _sellers.indexOf(s) % colors.length;
    final color = colors[idx];
    final initials = s.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return GestureDetector(
      onTap: () => _selectSeller(s),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                s.isOwner ? 'Owner' : 'Cashier',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSellers() => Expanded(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off_rounded, color: _kTextDim, size: 56),
          const SizedBox(height: 16),
          const Text(
            'No sellers added yet',
            style: TextStyle(
              color: _kText,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go to Settings → Sellers\nto add cashiers',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kTextDim, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Still allow owner to proceed without sellers
          GestureDetector(
            onTap: () {
              // Create a temporary owner session so permissions work
              SellerSession.instance.login(
                const Seller(id: 0, name: 'Owner', pin: '', role: 'owner'),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Continue as Owner',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── PIN entry ──────────────────────────────────────────────────────────────
  Widget _buildPinEntry() {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Back
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: _back,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _kTextDim,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Back',
                      style: TextStyle(color: _kTextDim, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Avatar
        _buildAvatar(_selected!),
        const SizedBox(height: 12),
        Text(
          _selected!.name,
          style: const TextStyle(
            color: _kText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _selected!.isOwner ? 'Owner' : 'Cashier',
          style: const TextStyle(color: _kTextDim, fontSize: 13),
        ),
        const SizedBox(height: 32),

        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final filled = i < _pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? _kAccent : Colors.transparent,
                border: Border.all(
                  color: filled ? _kAccent : _kTextDim,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          _error.isEmpty ? 'Enter your PIN' : _error,
          style: TextStyle(
            color: _error.isEmpty ? _kTextDim : _kDanger,
            fontSize: 13,
          ),
        ),

        const Spacer(),

        // Keypad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              ...[
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', 'del'],
              ].map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((k) {
                      if (k.isEmpty) {
                        return const SizedBox(width: 72, height: 72);
                      }
                      return GestureDetector(
                        onTap: k == 'del' ? _onDelete : () => _onKey(k),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _kCard,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: k == 'del'
                                ? const Icon(
                                    Icons.backspace_outlined,
                                    color: _kTextDim,
                                    size: 22,
                                  )
                                : Text(
                                    k,
                                    style: const TextStyle(
                                      color: _kText,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAvatar(Seller s) {
    final colors = [
      _kAccent,
      _kGreen,
      const Color(0xFFFFB547),
      const Color(0xFFFF85A2),
    ];
    final color = colors[_sellers.indexOf(s) % colors.length];
    final initials = s.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
