import '_model_value.dart';

class KegiatanModel {
  const KegiatanModel({
    this.id,
    required this.judul,
    this.isi,
    required this.tanggal,
    this.lokasi,
    this.publikasi = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String judul;
  final String? isi;
  final DateTime tanggal;
  final String? lokasi;
  final bool publikasi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory KegiatanModel.fromMap(Map<String, dynamic> map) {
    return KegiatanModel(
      id: toIntValue(map['id']),
      judul: toStringValue(map['judul']),
      isi: toNullableString(map['isi']),
      tanggal:
          toDateTimeValue(map['tanggal']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lokasi: toNullableString(map['lokasi']),
      publikasi: toBoolValue(map['publikasi'], fallback: true),
      createdAt: toDateTimeValue(map['created_at']),
      updatedAt: toDateTimeValue(map['updated_at']),
    );
  }

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel.fromMap(json);
  }

  bool get sudahLewat => tanggal.isBefore(DateTime.now());

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'judul': judul.trim(),
      'isi': isi,
      'tanggal': dateToSql(tanggal),
      'lokasi': lokasi,
      'publikasi': publikasi ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      ...toDatabaseMap(includeId: true),
      'sudah_lewat': sudahLewat,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
