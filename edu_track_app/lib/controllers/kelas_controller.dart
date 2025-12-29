import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/akademik_model.dart';

class ClassController {
  // Referensi ke koleksi 'kelas' di Firestore
  final CollectionReference classCollection = FirebaseFirestore.instance
      .collection('kelas');

  // 1. GET: Mengambil data real-time (Stream)
  Stream<List<KelasModel>> getClasses() {
    return classCollection
        .orderBy(
          'urutan',
          descending: false,
        ) // Urutkan berdasarkan nomor urut (1, 2, 3...)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Konversi dari dokumen Firestore ke Object KelasModel
            return KelasModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // 2. CREATE: Menambah kelas baru
  Future<void> addClass(String nama, String deskripsi, int urutan) async {
    try {
      await classCollection.add({
        'nama_kelas': nama,
        'deskripsi': deskripsi,
        'urutan': urutan,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error jika perlu
      print("Error adding class: $e");
      rethrow;
    }
  }

  // 3. UPDATE: Edit Data Kelas (BARU)
  Future<void> updateClass(
    String docId,
    String nama,
    String deskripsi,
    int urutan,
  ) async {
    await classCollection.doc(docId).update({
      'nama_kelas': nama,
      'deskripsi': deskripsi,
      'urutan': urutan,
      'updated_at':
          FieldValue.serverTimestamp(), // Opsional: catat waktu update
    });
  }

  // 4. DELETE: Hapus Kelas (UPDATE)
  Future<void> deleteClass(String docId) async {
    await classCollection.doc(docId).delete();
  }
}
