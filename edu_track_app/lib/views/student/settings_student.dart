import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pastikan package intl ada
import '../../controllers/auth_controller.dart';
import '../auth/login_page.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({super.key});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  final Color headerColor = const Color(0xFF001144);
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  // Controller Text Field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _hpController =
      TextEditingController(); // TAMBAHAN BARU

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. Ambil Data dari Firestore
  Future<void> _loadUserData() async {
    if (user == null) return;

    // Email selalu dari Auth (Read Only)
    _emailController.text = user!.email ?? "";

    setState(() => _isLoading = true);

    try {
      DocumentSnapshot doc = await userCollection.doc(user!.uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        _namaController.text = data['nama_lengkap'] ?? user!.displayName ?? "";
        _tglLahirController.text = data['tgl_lahir'] ?? "";
        _kelasController.text = data['kelas'] ?? "";
        _hpController.text = data['no_hp'] ?? ""; // Ambil No HP
      } else {
        _namaController.text = user!.displayName ?? "";
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Simpan Data ke Firestore
  Future<void> _saveProfile() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama Lengkap wajib diisi")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // A. Update Auth (Display Name) agar di Sidebar berubah
      await user?.updateDisplayName(_namaController.text);

      // B. Simpan ke Firestore
      await userCollection.doc(user!.uid).set({
        'uid': user!.uid,
        'email': user!.email,
        'nama_lengkap': _namaController.text,
        'tgl_lahir': _tglLahirController.text,
        'kelas': _kelasController.text,
        'no_hp': _hpController.text, // Simpan No HP
        'role': 'pelajar', // Pastikan role tetap aman
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge agar field lain tidak terhapus

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil disimpan!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper: Pilih Tanggal
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

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
            decoration: BoxDecoration(color: headerColor),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Data Diri Siswa",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ================= FORM INPUT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // FOTO PROFIL
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Foto profil diambil dari Akun Google",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 20),

                  // KOTAK FORM
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. EMAIL
                        _buildLabel("Email (Tidak dapat diubah)"),
                        TextField(
                          controller: _emailController,
                          readOnly: true,
                          style: TextStyle(color: Colors.grey[600]),
                          decoration: _inputDecor(
                            Icons.email_outlined,
                          ).copyWith(filled: true, fillColor: Colors.grey[100]),
                        ),
                        const SizedBox(height: 16),

                        // 2. NAMA LENGKAP
                        _buildLabel("Nama Lengkap"),
                        TextField(
                          controller: _namaController,
                          decoration: _inputDecor(Icons.person_outline),
                        ),
                        const SizedBox(height: 16),

                        // 3. TANGGAL LAHIR
                        _buildLabel("Tanggal Lahir"),
                        TextField(
                          controller: _tglLahirController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: _inputDecor(
                            Icons.calendar_today,
                          ).copyWith(hintText: "Pilih tanggal lahir"),
                        ),
                        const SizedBox(height: 16),

                        // 4. KELAS
                        _buildLabel("Kelas"),
                        TextField(
                          controller: _kelasController,
                          decoration: _inputDecor(
                            Icons.school_outlined,
                          ).copyWith(hintText: "Contoh: 6 SD"),
                        ),
                        const SizedBox(height: 16),

                        // 5. NO HP (BARU)
                        _buildLabel("Nomor HP / WhatsApp"),
                        TextField(
                          controller: _hpController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecor(
                            Icons.phone_android_outlined,
                          ).copyWith(hintText: "Contoh: 08123456789"),
                        ),

                        const SizedBox(height: 30),

                        // TOMBOL SIMPAN
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: headerColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveProfile,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Simpan Data",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton.icon(
                      onPressed: () async {
                        await AuthController().logout();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "Keluar Akun",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Styles
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecor(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}