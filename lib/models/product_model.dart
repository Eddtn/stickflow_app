// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';

// class ProductModel extends Equatable {
//   final String productId;
//   final String name;
//   final String sku;
//   final String category;
//   final int quantity;
//   final int lowStockThreshold;
//   final double unitPrice;
//   final String? imageUrl;
//   final String createdBy;
//   final DateTime updatedAt;

//   const ProductModel({
//     required this.productId,
//     required this.name,
//     required this.sku,
//     required this.category,
//     required this.quantity,
//     required this.lowStockThreshold,
//     required this.unitPrice,
//     this.imageUrl,
//     required this.createdBy,
//     required this.updatedAt,
//   });

//   bool get isLowStock => quantity <= lowStockThreshold;
//   bool get isOutOfStock => quantity == 0;

//   factory ProductModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return ProductModel(
//       productId: doc.id,
//       name: data['name'] ?? '',
//       sku: data['sku'] ?? '',
//       category: data['category'] ?? '',
//       quantity: data['quantity'] ?? 0,
//       lowStockThreshold: data['lowStockThreshold'] ?? 5,
//       unitPrice: (data['unitPrice'] ?? 0).toDouble(),
//       imageUrl: data['imageUrl'],
//       createdBy: data['createdBy'] ?? '',
//       updatedAt: (data['updatedAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'name': name,
//       'sku': sku,
//       'category': category,
//       'quantity': quantity,
//       'lowStockThreshold': lowStockThreshold,
//       'unitPrice': unitPrice,
//       'imageUrl': imageUrl,
//       'createdBy': createdBy,
//       'updatedAt': Timestamp.fromDate(updatedAt),
//     };
//   }

//   ProductModel copyWith({
//     String? productId,
//     String? name,
//     String? sku,
//     String? category,
//     int? quantity,
//     int? lowStockThreshold,
//     double? unitPrice,
//     String? imageUrl,
//     String? createdBy,
//     DateTime? updatedAt,
//   }) {
//     return ProductModel(
//       productId: productId ?? this.productId,
//       name: name ?? this.name,
//       sku: sku ?? this.sku,
//       category: category ?? this.category,
//       quantity: quantity ?? this.quantity,
//       lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
//       unitPrice: unitPrice ?? this.unitPrice,
//       imageUrl: imageUrl ?? this.imageUrl,
//       createdBy: createdBy ?? this.createdBy,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         productId,
//         name,
//         sku,
//         category,
//         quantity,
//         lowStockThreshold,
//         unitPrice,
//         imageUrl,
//         createdBy,
//         updatedAt,
//       ];
// }
