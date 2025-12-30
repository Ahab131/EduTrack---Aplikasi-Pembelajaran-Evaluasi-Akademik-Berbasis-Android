import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // 1. GET User by Role
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

  // 2. UPDATE User (Tambahkan parameter kelas)
  Future<void> updateUser(String uid, String nama, String noHp, String kelas) async {
    await userCollection.doc(uid).update({
      'nama_lengkap': nama,
      'no_hp': noHp,
      'kelas': kelas, // <--- UPDATE FIELD KELAS
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. DELETE User
  Future<void> deleteUser(String uid) async {
    await userCollection.doc(uid).delete();
  }
}