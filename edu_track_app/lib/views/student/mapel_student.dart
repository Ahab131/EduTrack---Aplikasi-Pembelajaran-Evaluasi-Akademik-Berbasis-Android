import 'package:flutter/material.dart';
import '../../controllers/mapel_controller.dart';
import '../../models/akademik_model.dart'; 
import 'materi_student.dart';

class StudentSubjectPage extends StatefulWidget {
  final KelasModel kelas;

  const StudentSubjectPage({super.key, required this.kelas});

  @override
  State<StudentSubjectPage> createState() => _StudentSubjectPageState();
}

class _StudentSubjectPageState extends State<StudentSubjectPage> {
  final Color headerColor = const Color(0xFF001144);
  final SubjectController _subjectController = SubjectController();

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
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tombol Kembali
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    
                    const SizedBox(width: 8),

                    // Teks Judul & Info Kelas
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mata Pelajaran",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.kelas.namaKelas, 
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          /// ================= LIST DATA MAPEL =================
          Expanded(
            child: StreamBuilder<List<MapelModel>>(
              stream: _subjectController.getSubjectsByClass(widget.kelas.id),
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
                        Icon(Icons.menu_book, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada pelajaran",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // 3. Ada Data
                final mapels = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mapels.length,
                  itemBuilder: (context, index) {
                    return _buildMapelCard(mapels[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= KARTU MAPEL (Card) =================
  Widget _buildMapelCard(MapelModel mapel, int index) {
    final List<Color> colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red];
    final Color iconColor = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
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
             MaterialPageRoute(builder: (_) => StudentMaterialPage(mapel: mapel)),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.book, color: iconColor),
        ),
        title: Text(
          mapel.namaMapel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          mapel.kategori,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}