import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // 1. GET: Ambil Semua User berdasarkan Role (Stream)
  // role: 'pelajar', 'admin', atau 'guru'
  Stream<List<UserModel>> getUsersByRole(String role) {
    return userCollection
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // 2. GET: Ambil Semua User (Tanpa Filter)
  Stream<List<UserModel>> getAllUsers() {
    return userCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // 3. UPDATE: Edit Data User
  Future<void> updateUser(String uid, String nama, String alamat, String noHp) async {
    await userCollection.doc(uid).update({
      'nama_lengkap': nama,
      'alamat': alamat,
      'no_hp': noHp, // Pastikan field ini ada di Firestore atau sesuaikan
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 4. DELETE: Hapus User dari Firestore
  // Catatan: Ini hanya menghapus data di database, bukan di Firebase Auth (Email/Password).
  // Untuk menghapus Auth, perlu Cloud Functions (Advanced).
  Future<void> deleteUser(String uid) async {
    await userCollection.doc(uid).delete();
  }
}