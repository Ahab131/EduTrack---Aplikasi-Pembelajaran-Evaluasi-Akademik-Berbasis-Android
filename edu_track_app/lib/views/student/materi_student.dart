import 'package:flutter/material.dart';
import '../../controllers/materi_controller.dart';
import '../../models/akademik_model.dart';
import 'detail_materi_student.dart'; 

class StudentMaterialPage extends StatefulWidget {
  final MapelModel mapel;

  const StudentMaterialPage({super.key, required this.mapel});

  @override
  State<StudentMaterialPage> createState() => _StudentMaterialPageState();
}

class _StudentMaterialPageState extends State<StudentMaterialPage> {
  final Color headerColor = const Color(0xFF001144); // Warna Biru Gelap
  final MaterialController _materialController = MaterialController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          /// ================= HEADER KOTAK =================
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              // Tanpa borderRadius (Kotak)
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Tombol Kembali
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    
                    const SizedBox(width: 8),

                    // Judul & Nama Mapel
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Daftar Materi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.mapel.namaMapel, // Menampilkan Mapel (misal: Matematika)
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ================= LIST MATERI =================
          Expanded(
            child: StreamBuilder<List<MateriModel>>(
              // Mengambil materi berdasarkan ID Mapel
              stream: _materialController.getMaterialsBySubject(widget.mapel.id),
              builder: (context, snapshot) {
                // 1. Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Kosong
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_outlined, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada materi saat ini",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // 3. Ada Data
                final materials = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    return _buildMaterialCard(materials[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= WIDGET KARTU MATERI =================
  Widget _buildMaterialCard(MateriModel materi, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailMateriStudent(materi: materi)),
          );
        },
        // Icon di Kiri
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.article, color: Colors.indigo),
        ),
        // Judul Materi
        title: Text(
          materi.judul,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // Preview Isi (sedikit)
        subtitle: Text(
          "Klik untuk membaca & kuis",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        // Panah
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}