class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role;
  final String? fotoUrl;
  final String? alamat; 
  final String? tanggalLahir;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.fotoUrl,
    this.alamat,
    this.tanggalLahir,
  });

  // 1. Mengubah Data dari Firestore (Map) ke Object Dart
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nama: data['nama_lengkap'] ?? 'Tanpa Nama',
      role: data['role'] ?? 'pelajar',
      fotoUrl: data['foto_url'],
      alamat: data['alamat'], 
      tanggalLahir: data['tanggal_lahir'],
    );
  }

  // 2. Mengubah Object Dart ke format Firestore (Map)
  // Dipakai saat menyimpan data user baru
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama_lengkap': nama,
      'role': role,
      'foto_url': fotoUrl,
      'alamat': alamat,
      'tanggal_lahir': tanggalLahir,
      'last_login': DateTime.now(),
    };
  }
}