import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthController {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- FUNGSI 1: LOGIN ADMIN (Email & Password) ---
  Future<UserModel?> loginAdmin(String email, String password, BuildContext context) async {
    try {
      // A. Login ke Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // B. Ambil data detail dari Firestore
        DocumentSnapshot doc = await _firestore.collection('tb_users').doc(firebaseUser.uid).get();

        if (doc.exists) {
          // Konversi data database ke Model
          UserModel userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);

          // C. Validasi Role (Security Check)
          if (userModel.role == 'admin') {
            return userModel; // SUKSES: Kembalikan data admin
          } else {
            // Kalau role-nya pelajar tapi coba login di form admin
            await _auth.signOut();
            _showError(context, 'Akun ini bukan Admin!');
            return null;
          }
        } else {
          _showError(context, 'Data user tidak ditemukan di database.');
          return null;
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle error spesifik Firebase
      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') message = 'Email tidak terdaftar.';
      else if (e.code == 'wrong-password') message = 'Password salah.';
      _showError(context, message);
    } catch (e) {
      _showError(context, 'Error: $e');
    }
    return null;
  }

  // --- FUNGSI 2: LOGIN PELAJAR (Google Sign-In) ---
  Future<UserModel?> loginWithGoogle(BuildContext context) async {
    try {
      // A. Buka Pop-up Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User batal milih akun

      // B. Ambil Token Autentikasi
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // C. Login ke Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // D. Cek apakah user sudah ada di database?
        DocumentSnapshot doc = await _firestore.collection('tb_users').doc(firebaseUser.uid).get();

        UserModel finalUser;

        if (doc.exists) {
          // -- KONDISI 1: SISWA LAMA --
          // Ambil datanya saja
          finalUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          // -- KONDISI 2: SISWA BARU (Auto Register) --
          // Siapkan data baru
          finalUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            nama: firebaseUser.displayName ?? 'Siswa Baru',
            role: 'pelajar', // Paksa jadi pelajar
            fotoUrl: firebaseUser.photoURL,
          );

          // Simpan ke Firestore (tb_users)
          await _firestore.collection('tb_users').doc(firebaseUser.uid).set(finalUser.toMap());
        }

        return finalUser; // SUKSES
      }
    } catch (e) {
      _showError(context, 'Gagal Login Google: $e');
    }
    return null;
  }

  // --- FUNGSI 3: LOGOUT ---
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Helper: Menampilkan Pesan Error (Snackbar)
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}