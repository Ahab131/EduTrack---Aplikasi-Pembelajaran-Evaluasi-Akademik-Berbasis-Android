import 'package:flutter/material.dart';
import '../../models/akademik_model.dart';
import 'manage_mapel.dart';
import '../../controllers/kelas_controller.dart';

class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({super.key});

  @override
  State<ManageClassesPage> createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  final Color primaryColor = const Color(0xFF6C63FF);
  final ClassController _classController = ClassController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Daftar Kelas",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        // Panggil dialog tanpa parameter untuk mode "Tambah"
        onPressed: () => _showFormDialog(context, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah Kelas",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<KelasModel>>(
        stream: _classController.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data kelas"));
          }

          final classes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return _buildClassCard(classes[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildClassCard(KelasModel kelas) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Klik kartu untuk masuk ke Mapel
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ManageSubjectsPage(kelas: kelas)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Nomor Urut
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "${kelas.urutan}",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informasi Kelas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas.namaKelas,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      kelas.deskripsi,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Menu Opsi (Edit/Hapus)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showFormDialog(context, kelas); // Buka dialog mode Edit
                  } else if (value == 'delete') {
                    _confirmDelete(context, kelas); // Konfirmasi Hapus
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
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

  // Dialog Form yang fleksibel (Bisa Tambah / Edit)
  void _showFormDialog(BuildContext context, KelasModel? kelas) {
    final bool isEdit = kelas != null; // Cek apakah ini mode edit

    // Jika edit, isi controller dengan data lama
    final TextEditingController namaController = TextEditingController(
      text: isEdit ? kelas.namaKelas : '',
    );
    final TextEditingController deskripsiController = TextEditingController(
      text: isEdit ? kelas.deskripsi : '',
    );
    final TextEditingController urutanController = TextEditingController(
      text: isEdit ? kelas.urutan.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Kelas" : "Tambah Kelas Baru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: "Nama Kelas"),
                ),
                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                ),
                TextField(
                  controller: urutanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Urutan"),
                ),
              ],
            ),
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
                  final int urutan = int.tryParse(urutanController.text) ?? 0;

                  if (isEdit) {
                    // Update Data Lama
                    await _classController.updateClass(
                      kelas.id, // ID Dokumen Firestore
                      namaController.text,
                      deskripsiController.text,
                      urutan,
                    );
                  } else {
                    // Tambah Data Baru
                    await _classController.addClass(
                      namaController.text,
                      deskripsiController.text,
                      urutan,
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
        );
      },
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(BuildContext context, KelasModel kelas) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Kelas?"),
        content: Text(
          "Apakah Anda yakin ingin menghapus '${kelas.namaKelas}'? Data yang dihapus tidak bisa dikembalikan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await _classController.deleteClass(
                kelas.id,
              ); // Panggil fungsi hapus
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
