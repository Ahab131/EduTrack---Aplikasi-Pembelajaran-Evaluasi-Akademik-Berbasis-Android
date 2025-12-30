import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_page.dart';
import 'manage_kelas.dart';
import 'manage_users.dart';
import 'laporan_nilai.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 1. APPBAR BIASA (Sederhana & Jelas)
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
            onPressed: () async {
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
        ],
      ),

      // 2. ISI DASHBOARD
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks Sapaan
            const Text(
              "Halo, Admin!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Silakan pilih menu untuk mengelola data.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Grid Menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 Kolom
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2, // Perbandingan lebar:tinggi kartu
                children: [
                  // MENU 1: KURIKULUM
                  _buildMenuCard(
                    context,
                    title: "Kelola\nKurikulum",
                    icon: Icons.school,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageClassesPage(),
                        ),
                      );
                    },
                  ),

                  // MENU 2: PENGGUNA (SISWA)
                  _buildMenuCard(
                    context,
                    title: "Data\nPengguna",
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageUsersPage(),
                        ),
                      );
                    },
                  ),

                  // MENU 3: NILAI
                  _buildMenuCard(
                    context,
                    title: "Laporan\nNilai",
                    icon: Icons.bar_chart,
                    color: Colors.teal,
                    onTap: () {
                      // UPDATE BAGIAN INI:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LaporanNilaiAdmin(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU MENU SEDERHANA
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Bulat
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              // Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
