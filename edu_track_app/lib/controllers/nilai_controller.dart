import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/akademik_model.dart';

class GradeController {
  final CollectionReference gradeCollection = FirebaseFirestore.instance.collection('nilai');

  // 1. SIMPAN NILAI
  Future<void> saveScore(String materiId, String judulMateri, int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await gradeCollection.add({
      'siswa_id': user.uid,
      'materi_id': materiId,
      'judul_materi': judulMateri,
      'nilai': score,
      'tanggal': FieldValue.serverTimestamp(),
    });
  }

  // 2. AMBIL RIWAYAT
  Stream<List<NilaiModel>> getStudentHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return gradeCollection
        .where('siswa_id', isEqualTo: user.uid)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NilaiModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // KHUSUS ADMIN: Ambil SEMUA Nilai dari semua siswa
  Stream<List<NilaiModel>> getAllGrades() {
    return gradeCollection
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NilaiModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // KHUSUS ADMIN: Hapus Nilai
  Future<void> deleteGrade(String docId) async {
    await gradeCollection.doc(docId).delete();
  }
}