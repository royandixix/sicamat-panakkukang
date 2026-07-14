import '_model_value.dart';

class LayananModel {
  const LayananModel({
    this.id,
    required this.nama,
    this.sektor,
    this.deskripsi,
    this.persyaratan,
    this.estimasiHari = 1,
    this.biaya = 0,
    this.aktif = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String nama;
  final String? sektor;
  final String? deskripsi;
  final String? persyaratan;
  final int estimasiHari;
  final double biaya;
  final bool aktif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LayananModel.fromMap(Map<String, dynamic> map) {
    return LayananModel(
      id: toIntValue(map['id']),
      nama: toStringValue(map['nama']),
      sektor: toNullableString(map['sektor']),
      deskripsi: toNullableString(map['deskripsi']),
      persyaratan: toNullableString(map['persyaratan']),
      estimasiHari: toIntValue(map['estimasi_hari']) ?? 1,
      biaya: toDoubleValue(map['biaya']) ?? 0,
      aktif: toBoolValue(map['aktif'], fallback: true),
      createdAt: toDateTimeValue(map['created_at']),
      updatedAt: toDateTimeValue(map['updated_at']),
    );
  }

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel.fromMap(json);
  }

  bool get gratis => biaya <= 0;

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'nama': nama.trim(),
      'sektor': sektor,
      'deskripsi': deskripsi,
      'persyaratan': persyaratan,
      'estimasi_hari': estimasiHari,
      'biaya': biaya,
      'aktif': aktif ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      ...toDatabaseMap(includeId: true),
      'gratis': gratis,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
