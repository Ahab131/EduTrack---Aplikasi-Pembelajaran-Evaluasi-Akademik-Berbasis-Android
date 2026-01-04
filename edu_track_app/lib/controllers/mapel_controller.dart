import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/akademik_model.dart';

class SubjectController {
  final CollectionReference subjectCollection = FirebaseFirestore.instance.collection('mata_pelajaran');

  // 1. GET: Ambil Mapel berdasarkan Kelas ID (Filter)
  Stream<List<MapelModel>> getSubjectsByClass(String kelasId) {
    return subjectCollection
        .where('kelas_id', isEqualTo: kelasId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MapelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. CREATE: Tambah Mapel Baru
  Future<void> addSubject(String nama, String kategori, String kelasId) async {
    await subjectCollection.add({
      'nama_mapel': nama,
      'kategori': kategori,
      'kelas_id': kelasId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. UPDATE: Edit Mapel
  Future<void> updateSubject(String docId, String nama, String kategori) async {
    await subjectCollection.doc(docId).update({
      'nama_mapel': nama,
      'kategori': kategori,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 4. DELETE: Hapus Mapel
  Future<void> deleteSubject(String docId) async {
    await subjectCollection.doc(docId).delete();
  }
}