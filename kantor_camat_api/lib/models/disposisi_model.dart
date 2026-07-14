import '_model_value.dart';

class DisposisiModel {
  const DisposisiModel({
    this.id,
    required this.suratId,
    required this.dariUserId,
    required this.keUserId,
    this.catatan,
    this.batasWaktu,
    this.status = 'dikirim',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int suratId;
  final int dariUserId;
  final int keUserId;
  final String? catatan;
  final DateTime? batasWaktu;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DisposisiModel.fromMap(Map<String, dynamic> map) {
    return DisposisiModel(
      id: toIntValue(map['id']),
      suratId: toIntValue(map['surat_id']) ?? 0,
      dariUserId: toIntValue(map['dari_user_id']) ?? 0,
      keUserId: toIntValue(map['ke_user_id']) ?? 0,
      catatan: toNullableString(map['catatan']),
      batasWaktu: toDateTimeValue(map['batas_waktu']),
      status: toStringValue(map['status'], fallback: 'dikirim'),
      createdAt: toDateTimeValue(map['created_at']),
      updatedAt: toDateTimeValue(map['updated_at']),
    );
  }

  factory DisposisiModel.fromJson(Map<String, dynamic> json) {
    return DisposisiModel.fromMap(json);
  }

  bool get selesai => status == 'selesai';

  bool get terlambat {
    if (batasWaktu == null || selesai) return false;
    return batasWaktu!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'surat_id': suratId,
      'dari_user_id': dariUserId,
      'ke_user_id': keUserId,
      'catatan': catatan,
      'batas_waktu': batasWaktu == null ? null : dateToSql(batasWaktu!),
      'status': status,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      ...toDatabaseMap(includeId: true),
      'terlambat': terlambat,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
