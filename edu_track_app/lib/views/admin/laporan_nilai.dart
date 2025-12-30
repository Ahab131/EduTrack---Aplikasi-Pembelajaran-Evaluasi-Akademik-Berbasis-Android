import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../controllers/nilai_controller.dart';
import '../../models/akademik_model.dart';

class LaporanNilaiAdmin extends StatefulWidget {
  const LaporanNilaiAdmin({super.key});

  @override
  State<LaporanNilaiAdmin> createState() => _LaporanNilaiAdminState();
}

class _LaporanNilaiAdminState extends State<LaporanNilaiAdmin> {
  final GradeController _gradeController = GradeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text("Laporan Nilai Siswa"),
        elevation: 0,
      ),
      body: StreamBuilder<List<NilaiModel>>(
        stream: _gradeController.getAllGrades(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Data Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Belum ada data nilai masuk.", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // 3. Ada Data
          final grades = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grades.length,
            itemBuilder: (context, index) {
              return _buildGradeCard(grades[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildGradeCard(NilaiModel nilai) {
    // Format Tanggal
    final String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(nilai.tanggal);
    // Warna Nilai (Merah jika < 70, Hijau jika >= 70)
    final Color scoreColor = nilai.nilai >= 70 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Skor
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${nilai.nilai}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Mapel & Siswa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nilai.judulMateri, // Nama Materi
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      // WIDGET KHUSUS UNTUK AMBIL NAMA SISWA
                      _NamaSiswa(siswaId: nilai.siswaId),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                // Tombol Hapus
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => _confirmDelete(nilai.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Nilai?"),
        content: const Text("Data ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await _gradeController.deleteGrade(docId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET: Mengambil Nama Siswa dari ID ---
class _NamaSiswa extends StatelessWidget {
  final String siswaId;
  const _NamaSiswa({required this.siswaId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(siswaId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Memuat nama...", style: TextStyle(fontSize: 12, color: Colors.grey));
        }
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String nama = data['nama_lengkap'] ?? "Tanpa Nama";
          final String kelas = data['kelas'] ?? "-";
          
          return Text(
            "$nama ($kelas)", 
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          );
        }

        return const Text("Siswa tidak ditemukan", style: TextStyle(fontSize: 12, color: Colors.red));
      },
    );
  }
}