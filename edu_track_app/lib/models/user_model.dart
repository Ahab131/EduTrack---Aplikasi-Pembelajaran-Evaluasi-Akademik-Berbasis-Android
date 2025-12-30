class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role; // 'admin', 'pelajar', 'guru'
  final String? fotoUrl;
  final String? kelas; // <--- TAMBAHAN BARU
  final String? noHp;  // <--- TAMBAHAN BARU

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.fotoUrl,
    this.kelas,
    this.noHp,
  });

  // Konversi dari Firestore ke Model
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nama: data['nama_lengkap'] ?? '', // Pastikan key-nya 'nama_lengkap' sesuai database
      role: data['role'] ?? 'pelajar',
      fotoUrl: data['foto_url'],
      kelas: data['kelas'], // <--- BACA DARI DB
      noHp: data['no_hp'],  // <--- BACA DARI DB
    );
  }

  // Konversi dari Model ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama_lengkap': nama,
      'role': role,
      'foto_url': fotoUrl,
      'kelas': kelas, // <--- SIMPAN KE DB
      'no_hp': noHp,  // <--- SIMPAN KE DB
    };
  }
}