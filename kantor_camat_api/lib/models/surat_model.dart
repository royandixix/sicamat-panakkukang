import '_model_value.dart';

class SuratModel {
  const SuratModel({
    this.id,
    required this.nomorSurat,
    required this.jenis,
    required this.perihal,
    required this.pengirim,
    required this.tujuan,
    required this.tanggalSurat,
    this.tanggalDiterima,
    this.status = 'baru',
    this.fileUrl,
    this.clusterNo,
    this.clusterLabel,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String nomorSurat;
  final String jenis;
  final String perihal;
  final String pengirim;
  final String tujuan;
  final DateTime tanggalSurat;
  final DateTime? tanggalDiterima;
  final String status;
  final String? fileUrl;
  final int? clusterNo;
  final String? clusterLabel;
  final int createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SuratModel.fromMap(Map<String, dynamic> map) {
    return SuratModel(
      id: toIntValue(map['id']),
      nomorSurat: toStringValue(map['nomor_surat']),
      jenis: toStringValue(map['jenis']),
      perihal: toStringValue(map['perihal']),
      pengirim: toStringValue(map['pengirim']),
      tujuan: toStringValue(map['tujuan']),
      tanggalSurat:
          toDateTimeValue(map['tanggal_surat']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      tanggalDiterima: toDateTimeValue(map['tanggal_diterima']),
      status: toStringValue(map['status'], fallback: 'baru'),
      fileUrl: toNullableString(map['file_url']),
      clusterNo: toIntValue(map['cluster_no']),
      clusterLabel: toNullableString(map['cluster_label']),
      createdBy: toIntValue(map['created_by']) ?? 0,
      createdAt: toDateTimeValue(map['created_at']),
      updatedAt: toDateTimeValue(map['updated_at']),
    );
  }

  factory SuratModel.fromJson(Map<String, dynamic> json) {
    return SuratModel.fromMap(json);
  }

  bool get isSuratMasuk => jenis == 'masuk';
  bool get isSuratKeluar => jenis == 'keluar';
  bool get sudahDiklaster => clusterNo != null;

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'nomor_surat': nomorSurat.trim(),
      'jenis': jenis,
      'perihal': perihal.trim(),
      'pengirim': pengirim.trim(),
      'tujuan': tujuan.trim(),
      'tanggal_surat': dateToSql(tanggalSurat),
      'tanggal_diterima': tanggalDiterima == null
          ? null
          : dateToSql(tanggalDiterima!),
      'status': status,
      'file_url': fileUrl,
      'cluster_no': clusterNo,
      'cluster_label': clusterLabel,
      'created_by': createdBy,
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
