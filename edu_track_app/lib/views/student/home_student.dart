import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kelas_controller.dart';
import '../../models/akademik_model.dart';
import '../auth/login_page.dart';
import 'mapel_student.dart';
import 'riwayat_nilai.dart';
import 'settings_student.dart';

class HomeStudent extends StatefulWidget {
  const HomeStudent({super.key});

  @override
  State<HomeStudent> createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
  final Color headerColor = const Color(0xFF001144);
  final ClassController _classController = ClassController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],

      drawer: _buildSidebar(context),

      body: Column(
        children: [
          /// ================= HEADER =================
          Container(
            height: 120,
            decoration: BoxDecoration(color: headerColor),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      "Home",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 25,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// ================= GRID KELAS =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<KelasModel>>(
                stream: _classController.getClasses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Belum ada kelas tersedia"),
                    );
                  }

                  final data = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                        ),
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return _kelasCard(data[i]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= WIDGET CARD =================
  Widget _kelasCard(KelasModel kelas) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentSubjectPage(kelas: kelas)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 38, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              kelas.namaKelas,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SIDEBAR =================
  Widget _buildSidebar(BuildContext context) {
    // Ambil User ID saat ini
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              String displayName = "Nama Siswa";
              String displayEmail = currentUser?.email ?? "";
              String? photoUrl = currentUser?.photoURL;
              String status = "Pelajar";

              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                displayName = data['nama_lengkap'] ?? currentUser?.displayName ?? "Nama Siswa";
                if (data['kelas'] != null && data['kelas'].toString().isNotEmpty) {
                  status = "Kelas ${data['kelas']}";
                }
              }

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                  ),
                ),
                margin: EdgeInsets.zero,
                
                // Foto Profil
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                
                // Nama dari Firestore
                accountName: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Email atau Kelas
                accountEmail: Text(
                  "$displayEmail\n$status",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              );
            },
          ),
          
          const SizedBox(height: 10),

          // Menu Items
          _menuItem(
            Icons.home_rounded,
            "Beranda",
            () => Navigator.pop(context),
          ),
          _menuItem(Icons.history_edu_rounded, "Riwayat Nilai", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScorePage()),
            );
          }),

          _menuItem(Icons.settings_rounded, "Pengaturan Akun", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentSettingsPage()),
            );
          }),

          const Spacer(),

          const Divider(thickness: 1, height: 1),

          // Tombol Keluar
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              "Keluar Aplikasi",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await AuthController().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.grey[700], size: 26),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
