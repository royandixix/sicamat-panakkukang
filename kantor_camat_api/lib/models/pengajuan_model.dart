import '_model_value.dart';

class PengajuanModel {
  const PengajuanModel({
    this.id,
    required this.kode,
    required this.userId,
    required this.layananId,
    required this.judul,
    required this.deskripsi,
    this.lokasi,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.status = 'diajukan',
    this.catatanPetugas,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String kode;
  final int userId;
  final int layananId;
  final String judul;
  final String deskripsi;
  final String? lokasi;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final String status;
  final String? catatanPetugas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PengajuanModel.fromMap(Map<String, dynamic> map) {
    return PengajuanModel(
      id: toIntValue(map['id']),
      kode: toStringValue(map['kode']),
      userId: toIntValue(map['user_id']) ?? 0,
      layananId: toIntValue(map['layanan_id']) ?? 0,
      judul: toStringValue(map['judul']),
      deskripsi: toStringValue(map['deskripsi']),
      lokasi: toNullableString(map['lokasi']),
      tanggalMulai: toDateTimeValue(map['tanggal_mulai']),
      tanggalSelesai: toDateTimeValue(map['tanggal_selesai']),
      status: toStringValue(map['status'], fallback: 'diajukan'),
      catatanPetugas: toNullableString(map['catatan_petugas']),
      createdAt: toDateTimeValue(map['created_at']),
      updatedAt: toDateTimeValue(map['updated_at']),
    );
  }

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    return PengajuanModel.fromMap(json);
  }

  bool get selesai {
    return status == 'selesai' || status == 'disetujui' || status == 'ditolak';
  }

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'kode': kode.trim(),
      'user_id': userId,
      'layanan_id': layananId,
      'judul': judul.trim(),
      'deskripsi': deskripsi.trim(),
      'lokasi': lokasi,
      'tanggal_mulai': tanggalMulai == null ? null : dateToSql(tanggalMulai!),
      'tanggal_selesai': tanggalSelesai == null
          ? null
          : dateToSql(tanggalSelesai!),
      'status': status,
      'catatan_petugas': catatanPetugas,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      ...toDatabaseMap(includeId: true),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
