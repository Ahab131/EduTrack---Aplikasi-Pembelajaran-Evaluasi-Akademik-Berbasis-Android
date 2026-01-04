import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserController {
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ======================================================
  // BAGIAN 1: Controller Admin
  // ======================================================

  // 1. GET User by Role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _userCollection
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // 2. UPDATE User
  Future<void> updateUser(String uid, String nama, String noHp, String kelas) async {
    await _userCollection.doc(uid).update({
      'nama_lengkap': nama,
      'no_hp': noHp,
      'kelas': kelas,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. DELETE User
  Future<void> deleteUser(String uid) async {
    await _userCollection.doc(uid).delete();
  }

  // ======================================================
  // BAGIAN 2: Controller Pelajar
  // ======================================================

  // 4. Ambil Data Pelajar
  Future<UserModel?> getCurrentUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _userCollection.doc(currentUser.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          nama: currentUser.displayName ?? '',
          role: 'pelajar',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // 5. Update Profil Pelajar
  Future<void> updateStudentProfile({
    required String nama,
    required String tglLahir,
    required String kelas,
    required String noHp,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await currentUser.updateDisplayName(nama);
    await _userCollection.doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'email': currentUser.email,
      'nama_lengkap': nama,
      'tgl_lahir': tglLahir,
      'kelas': kelas,
      'no_hp': noHp,
      'role': 'pelajar',
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 6. Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}