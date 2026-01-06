import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- FUNGSI 1: LOGIN ADMIN (Email & Password) ---
  Future<UserModel?> loginAdmin(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          UserModel userModel = UserModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );

          if (userModel.role == 'admin') {
            return userModel;
          } else {
            await _auth.signOut();

            if (context.mounted) {
              _showError(context, 'Akun ini bukan Admin!');
            }
            return null;
          }
        } else {
          if (context.mounted) {
            _showError(context, 'Data user tidak ditemukan di database.');
          }
          return null;
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar.';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah.';
      }

      if (context.mounted) {
        _showError(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
    }
    return null;
  }

  // --- FUNGSI 2: LOGIN PELAJAR (Google Sign-In) ---
  Future<UserModel?> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        UserModel finalUser;

        if (doc.exists) {
          finalUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          finalUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            nama: firebaseUser.displayName ?? 'Siswa Baru',
            role: 'pelajar',
            fotoUrl: firebaseUser.photoURL,
          );

          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'uid': finalUser.uid,
            'email': finalUser.email,
            'nama_lengkap': finalUser.nama,
            'role': finalUser.role,
            'foto_url': finalUser.fotoUrl,
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        return finalUser;
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Gagal Login Google: $e');
      }
    }
    return null;
  }

  // --- FUNGSI 3: LOGOUT ---
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}