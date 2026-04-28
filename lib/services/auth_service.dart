// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart';

// // enum UserRole { admin, staff }

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//   User? get currentUser => _auth.currentUser;

//   // Future<UserRole> getUserRole(String uid) async {
//   //   final doc = await _db.collection('users').doc(uid).get();
//   //   final role = doc.data()?['role'] as String? ?? 'staff';
//   //   return role == 'admin' ? UserRole.admin : UserRole.staff;
//   // }

//   Future<UserRole> getUserRole(String uid) async {
//     final doc = await _db.collection('users').doc(uid).get();
//     final role = doc.data()?['role'] as String? ?? 'staff';

//     return role == 'admin' ? UserRole.admin : UserRole.staff;
//   }

//   Future<void> signIn({required String email, required String password}) async {
//     await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }

//   Future<void> createUser({
//     required String email,
//     required String password,
//     required String name,
//     required UserRole role,
//   }) async {
//     final credential = await _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     await _db.collection('users').doc(credential.user!.uid).set({
//       'uid': credential.user!.uid,
//       'name': name,
//       'email': email,
//       'role': role == UserRole.admin ? 'admin' : 'staff',
//       'createdAt': FieldValue.serverTimestamp(),
//       'isActive': true,
//     });
//   }

//   Future<void> signOut() async => _auth.signOut();

//   Future<void> resetPassword(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }
// }
