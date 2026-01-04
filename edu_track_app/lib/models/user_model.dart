class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role;
  final String? fotoUrl;
  final String? kelas;
  final String? noHp;
  final String? tglLahir;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.fotoUrl,
    this.kelas,
    this.noHp,
    this.tglLahir,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      nama: data['nama_lengkap'] ?? '',
      role: data['role'] ?? 'pelajar',
      fotoUrl: data['foto_url'],
      kelas: data['kelas'],
      noHp: data['no_hp'],
      tglLahir: data['tgl_lahir'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama_lengkap': nama,
      'role': role,
      'foto_url': fotoUrl,
      'kelas': kelas,
      'no_hp': noHp,
      'tgl_lahir': tglLahir,
      'updated_at': DateTime.now(),
    };
  }
}