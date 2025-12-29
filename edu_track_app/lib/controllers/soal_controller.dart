import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/akademik_model.dart';

class QuestionController {
  final CollectionReference questionCollection = FirebaseFirestore.instance.collection('soal');

  // 1. GET: Ambil Soal berdasarkan Materi ID
  Stream<List<SoalModel>> getQuestionsByMaterial(String materiId) {
    return questionCollection
        .where('materi_id', isEqualTo: materiId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SoalModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. CREATE: Tambah Soal
  Future<void> addQuestion({
    required String pertanyaan,
    required String a,
    required String b,
    required String c,
    required String d,
    required String kunci,
    required String materiId,
  }) async {
    await questionCollection.add({
      'pertanyaan': pertanyaan,
      'pilihan_a': a,
      'pilihan_b': b,
      'pilihan_c': c,
      'pilihan_d': d,
      'kunci_jawaban': kunci,
      'materi_id': materiId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. UPDATE: Edit Soal
  Future<void> updateQuestion({
    required String docId,
    required String pertanyaan,
    required String a,
    required String b,
    required String c,
    required String d,
    required String kunci,
  }) async {
    await questionCollection.doc(docId).update({
      'pertanyaan': pertanyaan,
      'pilihan_a': a,
      'pilihan_b': b,
      'pilihan_c': c,
      'pilihan_d': d,
      'kunci_jawaban': kunci,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 4. DELETE: Hapus Soal
  Future<void> deleteQuestion(String docId) async {
    await questionCollection.doc(docId).delete();
  }
}