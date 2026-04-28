// // ─── Stock Card ───────────────────────────────────────────────────

// import 'package:flutter/material.dart';
// import 'package:stockflow/core/constant.dart';
// import 'package:stockflow/models/product_model.dart';

// class StockCard extends StatelessWidget {
//   final ProductModel product;
//   final VoidCallback? onTap;

//   const StockCard({super.key, required this.product, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     Color statusColor = AppColors.success;
//     String statusText = 'In Stock';
//     if (product.isOutOfStock) {
//       statusColor = AppColors.danger;
//       statusText = 'Out of Stock';
//     } else if (product.isLowStock) {
//       statusColor = AppColors.warning;
//       statusText = 'Low Stock';
//     }

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Row(children: [
//           // Product icon / image
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: product.imageUrl != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.network(product.imageUrl!, fit: BoxFit.cover),
//                   )
//                 : const Icon(Icons.inventory_2_outlined,
//                     color: AppColors.primary, size: 22),
//           ),
//           const SizedBox(width: 12),
//           // Product info
//           Expanded(
//               child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(product.name,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: AppColors.textPrimary),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis),
//               const SizedBox(height: 2),
//               Text('SKU: ${product.sku}',
//                   style: const TextStyle(
//                       fontSize: 11, color: AppColors.textSecondary)),
//             ],
//           )),
//           // Qty + status
//           Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//             Text('${product.quantity}',
//                 style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 18,
//                     color: product.isOutOfStock
//                         ? AppColors.danger
//                         : AppColors.textPrimary)),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(statusText,
//                   style: TextStyle(
//                       fontSize: 10,
//                       color: statusColor,
//                       fontWeight: FontWeight.w600)),
//             ),
//           ]),
//         ]),
//       ),
//     );
//   }
// }
