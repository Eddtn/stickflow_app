// // lib/screens/products/barcode_screen.dart

// import 'package:flutter/material.dart';
// import 'package:barcode_widget/barcode_widget.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import '../../models/product_model.dart';

// import '../../core/utils.dart';

// class BarcodeScreen extends StatefulWidget {
//   final ProductModel product;
//   const BarcodeScreen({super.key, required this.product});

//   @override
//   State<BarcodeScreen> createState() => _BarcodeScreenState();
// }

// class _BarcodeScreenState extends State<BarcodeScreen> {
//   int _copies = 1;
//   String _barcodeType = 'code128';

//   Future<void> _printLabels() async {
//     final pdf = pw.Document();

//     // Build a grid of labels — 3 per row
//     final labels = List.generate(_copies, (_) => _buildLabel());

//     pdf.addPage(pw.Page(
//       build: (ctx) => pw.Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: labels,
//       ),
//     ));

//     await Printing.layoutPdf(onLayout: (_) => pdf.save());
//   }

//   pw.Widget _buildLabel() {
//     return pw.Container(
//       width: 150,
//       padding: const pw.EdgeInsets.all(8),
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey300),
//         borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text(widget.product.name,
//             style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
//             textAlign: pw.TextAlign.center),
//           pw.SizedBox(height: 4),
//           pw.BarcodeWidget(
//             barcode: pw.Barcode.code128(),
//             data: widget.product.sku,
//             width: 130,
//             height: 50,
//             drawText: true,
//             textStyle: const pw.TextStyle(fontSize: 8),
//           ),
//           pw.SizedBox(height: 4),
//           pw.Text(AppUtils.formatCurrency(widget.product.unitPrice),
//             style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Barcode Label')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Preview
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: Column(
//                 children: [
//                   Text(widget.product.name,
//                     style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//                   const SizedBox(height: 12),
//                   BarcodeWidget(
//                     barcode: Barcode.code128(),
//                     data: widget.product.sku,
//                     width: 220,
//                     height: 90,
//                     drawText: true,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(AppUtils.formatCurrency(widget.product.unitPrice),
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
//                       color: AppColors.primary)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Copies selector
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Number of labels', style: TextStyle(fontWeight: FontWeight.w500)),
//                 Row(children: [
//                   IconButton(
//                     icon: const Icon(Icons.remove_circle_outline),
//                     onPressed: () => setState(() => _copies = (_copies - 1).clamp(1, 100)),
//                   ),
//                   Text('$_copies', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                   IconButton(
//                     icon: const Icon(Icons.add_circle_outline),
//                     onPressed: () => setState(() => _copies = (_copies + 1).clamp(1, 100)),
//                   ),
//                 ]),
//               ],
//             ),

//             const Spacer(),

//             ElevatedButton.icon(
//               onPressed: _printLabels,
//               icon: const Icon(Icons.print),
//               label: Text('Print $_copies label${_copies > 1 ? 's' : ''}'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
