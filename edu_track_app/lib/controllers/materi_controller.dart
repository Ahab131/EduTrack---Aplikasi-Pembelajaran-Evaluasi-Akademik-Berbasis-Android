import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/akademik_model.dart';

class MaterialController {
  final CollectionReference materialCollection = FirebaseFirestore.instance.collection('materi');

  // 1. GET: Ambil Materi berdasarkan Mapel ID
  Stream<List<MateriModel>> getMaterialsBySubject(String mapelId) {
    return materialCollection
        .where('mapel_id', isEqualTo: mapelId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MateriModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. CREATE: Tambah Materi
  Future<void> addMaterial(String judul, String isi, String mapelId) async {
    await materialCollection.add({
      'judul': judul,
      'isi_materi': isi,
      'mapel_id': mapelId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // 3. UPDATE: Edit Materi
  Future<void> updateMaterial(String docId, String judul, String isi) async {
    await materialCollection.doc(docId).update({
      'judul': judul,
      'isi_materi': isi,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // 4. DELETE: Hapus Materi
  Future<void> deleteMaterial(String docId) async {
    await materialCollection.doc(docId).delete();
  }
}