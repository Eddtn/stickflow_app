// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';

// enum TransactionType { stockIn, stockOut }

// class TransactionModel extends Equatable {
//   final String txId;
//   final String productId;
//   final String productName;
//   final TransactionType type;
//   final int quantity;
//   final String reason;
//   final String performedBy;
//   final String performedByName;
//   final DateTime timestamp;
//   final String? note;
//   final int prevQty;
//   final int newQty;

//   const TransactionModel({
//     required this.txId,
//     required this.productId,
//     required this.productName,
//     required this.type,
//     required this.quantity,
//     required this.reason,
//     required this.performedBy,
//     required this.performedByName,
//     required this.timestamp,
//     this.note,
//     required this.prevQty,
//     required this.newQty,
//   });

//   factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return TransactionModel(
//       txId: doc.id,
//       productId: data['productId'] ?? '',
//       productName: data['productName'] ?? '',
//       type: data['type'] == 'in'
//           ? TransactionType.stockIn
//           : TransactionType.stockOut,
//       quantity: data['quantity'] ?? 0,
//       reason: data['reason'] ?? '',
//       performedBy: data['performedBy'] ?? '',
//       performedByName: data['performedByName'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//       note: data['note'],
//       prevQty: data['prevQty'] ?? 0,
//       newQty: data['newQty'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'productId': productId,
//       'productName': productName,
//       'type': type == TransactionType.stockIn ? 'in' : 'out',
//       'quantity': quantity,
//       'reason': reason,
//       'performedBy': performedBy,
//       'performedByName': performedByName,
//       'timestamp': Timestamp.fromDate(timestamp),
//       'note': note,
//       'prevQty': prevQty,
//       'newQty': newQty,
//     };
//   }

//   @override
//   List<Object?> get props => [txId, productId, type, quantity, timestamp];
// }
