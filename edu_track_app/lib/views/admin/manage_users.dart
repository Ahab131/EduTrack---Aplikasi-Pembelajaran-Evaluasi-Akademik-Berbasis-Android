import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Ada 2 Tab: Siswa & Admin
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6C63FF), // Warna ungu admin
          title: const Text("Kelola Pengguna"),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Daftar Siswa"),
              Tab(text: "Daftar Admin"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList("pelajar"), // Tab 1
            _buildUserList("admin"), // Tab 2
          ],
        ),
      ),
    );
  }

  // --- WIDGET LIST BUILDER ---
  Widget _buildUserList(String role) {
    return StreamBuilder<List<UserModel>>(
      stream: _userController.getUsersByRole(role),
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
                const Icon(Icons.person_off, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  "Belum ada data $role",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // 3. Ada Data
        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserCard(users[index]);
          },
        );
      },
    );
  }

  // --- KARTU USER ---
  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // FOTO PROFIL
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: user.fotoUrl != null
              ? NetworkImage(user.fotoUrl!)
              : null,
          child: user.fotoUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        // NAMA & EMAIL
        title: Text(
          user.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 12)),
            if (user.role == 'pelajar') // Tampilkan kelas jika dia siswa
              Text(
                "Kelas: ${user.kelas ?? '-'}",
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
          ],
        ),
        // TOMBOL AKSI (Edit & Hapus)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditDialog(user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(user),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG EDIT DATA ---
  void _showEditDialog(UserModel user) {
    final TextEditingController namaCtrl = TextEditingController(
      text: user.nama,
    );
    final TextEditingController kelasCtrl = TextEditingController(
      text: user.kelas ?? "",
    );
    final TextEditingController hpCtrl = TextEditingController(
      text: user.noHp ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Data Pengguna"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(labelText: "Nama Lengkap"),
                ),
                const SizedBox(height: 10),
                if (user.role == 'pelajar') // Hanya muncul jika siswa
                  TextField(
                    controller: kelasCtrl,
                    decoration: const InputDecoration(
                      labelText: "Kelas (Contoh: 6 SD)",
                    ),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: hpCtrl,
                  decoration: const InputDecoration(
                    labelText: "No HP",
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              onPressed: () async {
                // Panggil fungsi update yang baru
                await _userController.updateUser(
                  user.uid,
                  namaCtrl.text, // Nama
                  hpCtrl.text, // No HP
                  kelasCtrl.text, // Kelas (Tambahan)
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil diperbarui")),
                  );
                }
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- KONFIRMASI HAPUS ---
  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Pengguna?"),
          content: Text(
            "Yakin ingin menghapus ${user.nama}? Data yang dihapus tidak bisa dikembalikan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await _userController.deleteUser(user.uid);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pengguna dihapus")),
                  );
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}