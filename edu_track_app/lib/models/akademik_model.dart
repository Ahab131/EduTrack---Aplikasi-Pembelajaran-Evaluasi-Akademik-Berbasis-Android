import 'package:cloud_firestore/cloud_firestore.dart';

class KelasModel {
  final String id;
  final String namaKelas;
  final String deskripsi;
  final int urutan;

  KelasModel({
    required this.id,
    required this.namaKelas,
    required this.deskripsi,
    required this.urutan,
  });

  factory KelasModel.fromMap(Map<String, dynamic> data, String documentId) {
    return KelasModel(
      id: documentId,
      namaKelas: data['nama_kelas'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      urutan: data['urutan'] ?? 0,
    );
  }

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
  final String namaMapel;
  final String kategori;
  final String kelasId; 

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
  final String judul;
  final String isiMateri;
  final String mapelId;

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
  final String kunciJawaban;
  final String materiId;

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

class NilaiModel {
  final String id;
  final String siswaId;
  final String materiId;
  final String judulMateri;
  final int nilai;
  final DateTime tanggal; 

  NilaiModel({
    required this.id,
    required this.siswaId,
    required this.materiId,
    required this.judulMateri,
    required this.nilai,
    required this.tanggal,
  });

  factory NilaiModel.fromMap(Map<String, dynamic> data, String docId) {
    return NilaiModel(
      id: docId,
      siswaId: data['siswa_id'] ?? '',
      materiId: data['materi_id'] ?? '',
      judulMateri: data['judul_materi'] ?? 'Materi',
      nilai: data['nilai'] ?? 0,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'siswa_id': siswaId,
      'materi_id': materiId,
      'judul_materi': judulMateri,
      'nilai': nilai,
      'tanggal': tanggal,
    };
  }
}