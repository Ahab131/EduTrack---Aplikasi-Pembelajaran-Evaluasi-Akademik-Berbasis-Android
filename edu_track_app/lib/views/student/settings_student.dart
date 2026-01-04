import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Hanya butuh untuk ambil photoURL header (opsional)
import 'package:intl/intl.dart';
import '../../controllers/user_controller.dart'; // <--- Import Controller
import '../../models/user_model.dart';           // <--- Import Model
import '../auth/login_page.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({super.key});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  // Panggil Controller
  final UserController _userController = UserController(); 
  final Color headerColor = const Color(0xFF001144);
  
  // Controller Text Field (State UI tetap di View)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();

  bool _isLoading = false;
  User? _currentUser; // Untuk keperluan UI foto profil saja

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Opsional: hanya untuk display foto
    _fetchData(); // Panggil fungsi load dari Controller
  }

  // --- LOGIKA UI MEMANGGIL CONTROLLER ---

  // 1. Fetch Data
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Panggil Controller untuk ambil data
      UserModel? userModel = await _userController.getCurrentUserData();

      if (userModel != null) {
        _emailController.text = userModel.email;
        _namaController.text = userModel.nama;
        _tglLahirController.text = userModel.tglLahir ?? "";
        _kelasController.text = userModel.kelas ?? "";
        _hpController.text = userModel.noHp ?? "";
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Save Data
  Future<void> _handleSave() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama Lengkap wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Panggil Controller untuk simpan data
      await _userController.updateStudentProfile(
        nama: _namaController.text,
        tglLahir: _tglLahirController.text,
        kelas: _kelasController.text,
        noHp: _hpController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil disimpan!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. Logout
  Future<void> _handleLogout() async {
    await _userController.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // Helper Date Picker (Murni UI)
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
          /// HEADER
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(color: headerColor),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Data Diri Siswa",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// FORM INPUT
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
                      backgroundImage: _currentUser?.photoURL != null
                          ? NetworkImage(_currentUser!.photoURL!)
                          : null,
                      child: _currentUser?.photoURL == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
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
                        _buildLabel("Email (Tidak dapat diubah)"),
                        TextField(
                          controller: _emailController,
                          readOnly: true,
                          style: TextStyle(color: Colors.grey[600]),
                          decoration: _inputDecor(Icons.email_outlined).copyWith(filled: true, fillColor: Colors.grey[100]),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Nama Lengkap"),
                        TextField(
                          controller: _namaController,
                          decoration: _inputDecor(Icons.person_outline),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Tanggal Lahir"),
                        TextField(
                          controller: _tglLahirController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: _inputDecor(Icons.calendar_today).copyWith(hintText: "Pilih tanggal lahir"),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Kelas"),
                        TextField(
                          controller: _kelasController,
                          decoration: _inputDecor(Icons.school_outlined).copyWith(hintText: "Contoh: 6 SD"),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel("Nomor HP / WhatsApp"),
                        TextField(
                          controller: _hpController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecor(Icons.phone_android_outlined).copyWith(hintText: "Contoh: 08123456789"),
                        ),

                        const SizedBox(height: 30),

                        // TOMBOL SIMPAN
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: headerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _isLoading ? null : _handleSave, // Panggil fungsi wrapper
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Simpan Data", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      onPressed: _handleLogout, // Panggil fungsi wrapper
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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