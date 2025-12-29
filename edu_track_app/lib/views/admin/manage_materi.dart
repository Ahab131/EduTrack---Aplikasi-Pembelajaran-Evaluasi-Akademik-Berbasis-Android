import 'package:flutter/material.dart';
import'../../models/akademik_model.dart';
import '../../controllers/materi_controller.dart';
import  'manage_detail_materi.dart';

class ManageMaterialsPage extends StatefulWidget {
  final MapelModel mapel; // Menerima data Mapel yang dipilih

  const ManageMaterialsPage({super.key, required this.mapel});

  @override
  State<ManageMaterialsPage> createState() => _ManageMaterialsPageState();
}

class _ManageMaterialsPageState extends State<ManageMaterialsPage> {
  final Color primaryColor = const Color(0xFF6C63FF);
  final MaterialController _materialController = MaterialController();

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
              "Daftar Materi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "Mapel: ${widget.mapel.namaMapel}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => _showFormDialog(context, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Materi", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<MateriModel>>(
        stream: _materialController.getMaterialsBySubject(widget.mapel.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada materi di ${widget.mapel.namaMapel}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final materiList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materiList.length,
            itemBuilder: (context, index) {
              return _buildMaterialCard(materiList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(MateriModel materi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // NAVIGASI KE LEVEL 4: DETAIL MATERI & SOAL
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManageMaterialDetailPage(materi: materi), // Nanti dibuat
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.judul,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      materi.isiMateri,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showFormDialog(context, materi);
                  } else if (value == 'delete') {
                    _confirmDelete(context, materi);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [Icon(Icons.edit, color: Colors.blue, size: 20), SizedBox(width: 8), Text("Edit")],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text("Hapus")],
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

  void _showFormDialog(BuildContext context, MateriModel? materi) {
    final bool isEdit = materi != null;
    final TextEditingController judulController = TextEditingController(text: isEdit ? materi.judul : '');
    final TextEditingController isiController = TextEditingController(text: isEdit ? materi.isiMateri : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Materi" : "Tambah Materi Baru"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: "Judul Materi (misal: Bab 1)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: isiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Isi Materi / Deskripsi Singkat",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              if (judulController.text.isNotEmpty) {
                if (isEdit) {
                  await _materialController.updateMaterial(
                    materi.id,
                    judulController.text,
                    isiController.text,
                  );
                } else {
                  // Simpan dengan mapel_id dari widget.mapel.id
                  await _materialController.addMaterial(
                    judulController.text,
                    isiController.text,
                    widget.mapel.id,
                  );
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MateriModel materi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Materi?"),
        content: Text("Yakin ingin menghapus '${materi.judul}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await _materialController.deleteMaterial(materi.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}