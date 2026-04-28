// import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:csv/csv.dart';
// import 'package:stockflow/models/transact_model.dart';
// import '../models/product_model.dart';
// import '../core/utils.dart';

// class ReportService {
//   // ─── PDF Inventory Report ─────────────────────────────────────

//   static Future<void> exportInventoryPdf(List<ProductModel> products) async {
//     final pdf = pw.Document();

//     pdf.addPage(pw.MultiPage(
//       pageFormat: PdfPageFormat.a4,
//       margin: const pw.EdgeInsets.all(32),
//       build: (context) => [
//         pw.Header(
//           level: 0,
//           child: pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text('StockFlow — Inventory Report',
//                   style: pw.TextStyle(
//                       fontSize: 18, fontWeight: pw.FontWeight.bold)),
//               pw.Text(AppUtils.formatDate(DateTime.now()),
//                   style: const pw.TextStyle(fontSize: 12)),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 20),
//         pw.Table.fromTextArray(
//           headers: [
//             'Product',
//             'SKU',
//             'Category',
//             'Qty',
//             'Unit Price',
//             'Total Value',
//             'Status'
//           ],
//           data: products
//               .map((p) => [
//                     p.name,
//                     p.sku,
//                     p.category,
//                     '${p.quantity}',
//                     AppUtils.formatCurrency(p.unitPrice),
//                     AppUtils.formatCurrency(p.quantity * p.unitPrice),
//                     p.isOutOfStock
//                         ? 'Out of stock'
//                         : p.isLowStock
//                             ? 'Low stock'
//                             : 'OK',
//                   ])
//               .toList(),
//           headerStyle:
//               pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
//           cellStyle: const pw.TextStyle(fontSize: 9),
//           headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
//           cellAlignments: {
//             3: pw.Alignment.centerRight,
//             4: pw.Alignment.centerRight,
//             5: pw.Alignment.centerRight,
//           },
//         ),
//         pw.SizedBox(height: 20),
//         pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
//           pw.Text(
//             'Total Inventory Value: ${AppUtils.formatCurrency(products.fold(0.0, (s, p) => s + p.quantity * p.unitPrice))}',
//             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
//           ),
//         ]),
//       ],
//     ));

//     final dir = await getTemporaryDirectory();
//     final file = File(
//         '${dir.path}/inventory_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
//     await file.writeAsBytes(await pdf.save());
//     await Share.shareXFiles([XFile(file.path)], subject: 'Inventory Report');
//   }

//   // ─── PDF Transaction Report ───────────────────────────────────

//   static Future<void> exportTransactionsPdf(
//     List<TransactionModel> transactions, {
//     DateTime? from,
//     DateTime? to,
//   }) async {
//     final pdf = pw.Document();
//     final filtered = transactions.where((t) {
//       if (from != null && t.timestamp.isBefore(from)) return false;
//       if (to != null && t.timestamp.isAfter(to)) return false;
//       return true;
//     }).toList();

//     pdf.addPage(pw.MultiPage(
//       pageFormat: PdfPageFormat.a4,
//       margin: const pw.EdgeInsets.all(32),
//       build: (context) => [
//         pw.Header(
//           level: 0,
//           child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('StockFlow — Transaction Report',
//                     style: pw.TextStyle(
//                         fontSize: 18, fontWeight: pw.FontWeight.bold)),
//                 pw.SizedBox(height: 4),
//                 if (from != null && to != null)
//                   pw.Text(
//                       'Period: ${AppUtils.formatDate(from)} – ${AppUtils.formatDate(to)}',
//                       style: const pw.TextStyle(fontSize: 11)),
//               ]),
//         ),
//         pw.SizedBox(height: 20),
//         pw.Table.fromTextArray(
//           headers: ['Date', 'Product', 'Type', 'Qty', 'Reason', 'By'],
//           data: filtered
//               .map((t) => [
//                     AppUtils.formatDateTime(t.timestamp),
//                     t.productName,
//                     t.type == TransactionType.stockIn ? 'IN' : 'OUT',
//                     '${t.quantity}',
//                     t.reason,
//                     t.performedByName,
//                   ])
//               .toList(),
//           headerStyle:
//               pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
//           cellStyle: const pw.TextStyle(fontSize: 9),
//           headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
//         ),
//       ],
//     ));

//     final dir = await getTemporaryDirectory();
//     final file = File(
//         '${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf');
//     await file.writeAsBytes(await pdf.save());
//     await Share.shareXFiles([XFile(file.path)], subject: 'Transaction Report');
//   }

//   // ─── CSV Export ───────────────────────────────────────────────

//   static Future<void> exportInventoryCsv(List<ProductModel> products) async {
//     final rows = [
//       [
//         'Product',
//         'SKU',
//         'Category',
//         'Quantity',
//         'Unit Price',
//         'Total Value',
//         'Low Stock Threshold',
//         'Status'
//       ],
//       ...products.map((p) => [
//             p.name,
//             p.sku,
//             p.category,
//             p.quantity.toString(),
//             p.unitPrice.toString(),
//             (p.quantity * p.unitPrice).toString(),
//             p.lowStockThreshold.toString(),
//             p.isOutOfStock
//                 ? 'Out of Stock'
//                 : p.isLowStock
//                     ? 'Low Stock'
//                     : 'OK',
//           ]),
//     ];
//     final csv = const ListToCsvConverter().convert(rows);
//     final dir = await getTemporaryDirectory();
//     final file = File(
//         '${dir.path}/inventory_${DateTime.now().millisecondsSinceEpoch}.csv');
//     await file.writeAsString(csv);
//     await Share.shareXFiles([XFile(file.path)], subject: 'Inventory CSV');
//   }
// }
