// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';

// enum UserRole { admin, staff }

// class UserModel extends Equatable {
//   final String uid;
//   final String name;
//   final String email;
//   final UserRole role;
//   final DateTime createdAt;
//   final bool isActive;

//   const UserModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.role,
//     required this.createdAt,
//     required this.isActive,
//   });

//   bool get isAdmin => role == UserRole.admin;

//   factory UserModel.fromFirestore(DocumentSnapshot doc) {
//     final d = doc.data() as Map<String, dynamic>;
//     return UserModel(
//       uid: doc.id,
//       name: d['name'] ?? '',
//       email: d['email'] ?? '',
//       role: d['role'] == 'admin' ? UserRole.admin : UserRole.staff,
//       createdAt: d['createdAt'] != null
//           ? (d['createdAt'] as Timestamp).toDate()
//           : DateTime.now(),
//       isActive: d['isActive'] ?? true,
//     );
//   }

//   Map<String, dynamic> toFirestore() => {
//         'uid': uid,
//         'name': name,
//         'email': email,
//         'role': role == UserRole.admin ? 'admin' : 'staff',
//         'createdAt': Timestamp.fromDate(createdAt),
//         'isActive': isActive,
//       };

//   @override
//   List<Object?> get props => [uid, name, email, role, isActive];
// }
