import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Database

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Tes Koneksi Firebase")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('uji_coba').add({
                  'pesan': 'Halo Firebase!',
                  'waktu': DateTime.now().toString(),
                  'status': 'Berhasil Konek',
                });

                print("SUKSES! Data terkirim ke Firebase.");

              } catch (e) {
                print("GAGAL: $e");
              }
            },
            child: const Text("Klik untuk Tes Kirim Data"),
          ),
        ),
      ),
    );
  }
}