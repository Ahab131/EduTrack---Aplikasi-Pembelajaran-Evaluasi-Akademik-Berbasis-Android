class KelasModel {
  final String id;
  final String namaKelas; // Contoh: "Kelas 6 SD"
  final String deskripsi; // Contoh: "Tahun Ajaran 2023/2024"
  final int urutan; // Untuk sorting, misal kelas 1 dulu baru kelas 2

  KelasModel({
    required this.id,
    required this.namaKelas,
    required this.deskripsi,
    required this.urutan,
  });

  // Konversi dari Firestore ke Dart Object
  factory KelasModel.fromMap(Map<String, dynamic> data, String documentId) {
    return KelasModel(
      id: documentId,
      namaKelas: data['nama_kelas'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      urutan: data['urutan'] ?? 0,
    );
  }

  // Konversi dari Dart Object ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi,
      'urutan': urutan,
    };
  }
}

class MapelModel {
  final String id;
  final String namaMapel; // Contoh: "Matematika"
  final String kategori;  // Contoh: "Eksakta", "Bahasa"
  final String kelasId;   // Foreign Key: Mapel ini milik kelas mana

  MapelModel({
    required this.id,
    required this.namaMapel,
    required this.kategori,
    required this.kelasId,
  });

  factory MapelModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MapelModel(
      id: documentId,
      namaMapel: data['nama_mapel'] ?? '',
      kategori: data['kategori'] ?? 'Umum',
      kelasId: data['kelas_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_mapel': namaMapel,
      'kategori': kategori,
      'kelas_id': kelasId,
    };
  }
}

class MateriModel {
  final String id;
  final String judul;      // Judul Materi, misal "Perkalian Dasar"
  final String isiMateri;  // Bisa berupa teks panjang atau link PDF/Video
  final String mapelId;    // Relasi ke Mata Pelajaran

  MateriModel({
    required this.id,
    required this.judul,
    required this.isiMateri,
    required this.mapelId,
  });

  factory MateriModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MateriModel(
      id: documentId,
      judul: data['judul'] ?? '',
      isiMateri: data['isi_materi'] ?? '',
      mapelId: data['mapel_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'isi_materi': isiMateri,
      'mapel_id': mapelId,
    };
  }
}

class SoalModel {
  final String id;
  final String pertanyaan;
  final String pilihanA;
  final String pilihanB;
  final String pilihanC;
  final String pilihanD;
  final String kunciJawaban; // Contoh: 'A', 'B', 'C', atau 'D'
  final String materiId;     // Relasi ke Materi

  SoalModel({
    required this.id,
    required this.pertanyaan,
    required this.pilihanA,
    required this.pilihanB,
    required this.pilihanC,
    required this.pilihanD,
    required this.kunciJawaban,
    required this.materiId,
  });

  factory SoalModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SoalModel(
      id: documentId,
      pertanyaan: data['pertanyaan'] ?? '',
      pilihanA: data['pilihan_a'] ?? '',
      pilihanB: data['pilihan_b'] ?? '',
      pilihanC: data['pilihan_c'] ?? '',
      pilihanD: data['pilihan_d'] ?? '',
      kunciJawaban: data['kunci_jawaban'] ?? 'A',
      materiId: data['materi_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pertanyaan': pertanyaan,
      'pilihan_a': pilihanA,
      'pilihan_b': pilihanB,
      'pilihan_c': pilihanC,
      'pilihan_d': pilihanD,
      'kunci_jawaban': kunciJawaban,
      'materi_id': materiId,
    };
  }
}