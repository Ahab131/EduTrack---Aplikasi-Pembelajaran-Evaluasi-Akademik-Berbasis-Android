import 'package:flutter/material.dart';
import '../../models/akademik_model.dart';
import '../../controllers/mapel_controller.dart';
import 'manage_materi.dart';

class ManageSubjectsPage extends StatefulWidget {
  final KelasModel kelas; // Menerima data dari halaman sebelumnya

  const ManageSubjectsPage({super.key, required this.kelas});

  @override
  State<ManageSubjectsPage> createState() => _ManageSubjectsPageState();
}

class _ManageSubjectsPageState extends State<ManageSubjectsPage> {
  final Color primaryColor = const Color(0xFF6C63FF);
  final SubjectController _subjectController = SubjectController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mata Pelajaran",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Kelas: ${widget.kelas.namaKelas}", // Menampilkan konteks kelas
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => _showFormDialog(context, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah Mapel",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<MapelModel>>(
        // Memanggil fungsi GET dengan parameter ID Kelas
        stream: _subjectController.getSubjectsByClass(widget.kelas.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada mapel di ${widget.kelas.namaKelas}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final mapels = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mapels.length,
            itemBuilder: (context, index) {
              return _buildSubjectCard(mapels[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubjectCard(MapelModel mapel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // NAVIGASI KE LEVEL 3: MATERI
          // Membawa data Mapel ke halaman materi
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManageMaterialsPage(mapel: mapel),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Kategori Mapel
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book, color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 16),
              // Info Mapel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mapel.namaMapel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        mapel.kategori,
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Edit/Hapus
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showFormDialog(context, mapel);
                  } else if (value == 'delete') {
                    _confirmDelete(context, mapel);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text("Hapus"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Form Dialog (Tambah & Edit)
  void _showFormDialog(BuildContext context, MapelModel? mapel) {
    final bool isEdit = mapel != null;
    final TextEditingController namaController = TextEditingController(
      text: isEdit ? mapel.namaMapel : '',
    );
    // Kategori bisa dibuat Dropdown nanti, sementara Textfield dulu
    final TextEditingController kategoriController = TextEditingController(
      text: isEdit ? mapel.kategori : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Mata Pelajaran" : "Tambah Mata Pelajaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Mapel (misal: Matematika)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kategoriController,
              decoration: const InputDecoration(
                labelText: "Kategori (misal: Eksakta, Bahasa)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              if (namaController.text.isNotEmpty) {
                if (isEdit) {
                  await _subjectController.updateSubject(
                    mapel.id,
                    namaController.text,
                    kategoriController.text,
                  );
                } else {
                  // Saat menambah, kita masukkan ID KELAS dari widget.kelas.id
                  await _subjectController.addSubject(
                    namaController.text,
                    kategoriController.text,
                    widget.kelas.id, // PENTING: Foreign Key
                  );
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(
              isEdit ? "Update" : "Simpan",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(BuildContext context, MapelModel mapel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Mapel?"),
        content: Text("Yakin ingin menghapus '${mapel.namaMapel}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await _subjectController.deleteSubject(mapel.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
