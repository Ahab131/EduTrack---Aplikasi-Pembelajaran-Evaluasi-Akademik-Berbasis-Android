import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

// Import halaman tujuan (Nanti kita buat file dummy-nya di bawah)
import '../admin/dashboard_admin.dart';
import '../student/home_student.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Panggil Controller
  final AuthController _authController = AuthController();
  
  // 2. Controller untuk Form Input (Admin)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // 3. State untuk UI
  bool _isAdminMode = false; // Default false (Tampilan Siswa)
  bool _isLoading = false;   // Untuk efek loading muter-muter

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- FUNGSI NAVIGASI ---
  void _navigateBasedOnRole(UserModel user) {
    if (user.role == 'admin') {
      // Pindah ke Dashboard Admin (Hapus tombol back)
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const DashboardAdmin()),
      );
    } else {
      // Pindah ke Home Siswa (Hapus tombol back)
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const HomeStudent()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- LOGO APLIKASI ---
              const Icon(Icons.school_rounded, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text(
                "EduTrack",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const Text("Aplikasi Evaluasi & Pembelajaran", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // --- LOGIC TAMPILAN (SISWA vs ADMIN) ---
              if (_isLoading) 
                const CircularProgressIndicator() // Tampilkan loading jika sedang proses
              else if (!_isAdminMode) 
                _buildStudentView() // Tampilan Default (Siswa)
              else 
                _buildAdminView(),  // Tampilan Admin (Form)
              
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET TAMPILAN SISWA (GOOGLE) ---
  Widget _buildStudentView() {
    return Column(
      children: [
        const Text(
          "Masuk untuk mulai belajar",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        
        // Tombol Google
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.g_mobiledata, size: 30),
            label: const Text("MASUK DENGAN GOOGLE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              setState(() => _isLoading = true); // Mulai Loading
              
              // Panggil Controller
              UserModel? user = await _authController.loginWithGoogle(context);

              setState(() => _isLoading = false); // Stop Loading

              if (user != null) {
                _navigateBasedOnRole(user);
              }
            },
          ),
        ),
        
        const SizedBox(height: 40),
        const Divider(),
        TextButton(
          onPressed: () {
            setState(() {
              _isAdminMode = true; // Ganti ke Mode Admin
              _emailController.clear();
              _passController.clear();
            });
          },
          child: const Text("Masuk sebagai Admin / Guru"),
        ),
      ],
    );
  }

  // --- WIDGET TAMPILAN ADMIN (FORM) ---
  Widget _buildAdminView() {
    return Column(
      children: [
        const Text(
          "Login Administrator",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              setState(() => _isLoading = true);

              // Panggil Controller
              UserModel? user = await _authController.loginAdmin(
                _emailController.text.trim(), 
                _passController.text.trim(), 
                context
              );

              setState(() => _isLoading = false);

              if (user != null) {
                _navigateBasedOnRole(user);
              }
            },
            child: const Text("LOGIN ADMIN"),
          ),
        ),

        const SizedBox(height: 20),
        TextButton(
          onPressed: () => setState(() => _isAdminMode = false), // Kembali ke Mode Siswa
          child: const Text("Batal (Kembali ke Siswa)"),
        ),
      ],
    );
  }
}