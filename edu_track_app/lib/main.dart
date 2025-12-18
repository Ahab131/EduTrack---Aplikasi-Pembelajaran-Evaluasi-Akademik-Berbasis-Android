import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Halaman Login yang baru kita buat
import 'views/auth/login_page.dart';

void main() async {
  // 1. Wajib ditambahkan jika function main() menggunakan async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase sesuai platform (Android/iOS/Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" di pojok kanan atas
      title: 'EduTrack', // Judul Aplikasi
      theme: ThemeData(
        // Pengaturan Tema Warna
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Menggunakan desain Material 3 yang lebih modern
      ),
      
      // 4. Tentukan Halaman Awal
      // Kita langsung arahkan ke LoginPage
      home: const LoginPage(),
    );
  }
}