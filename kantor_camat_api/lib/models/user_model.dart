import '_model_value.dart';

class UserModel {
  const UserModel({
    this.id,
    required this.nama,
    required this.email,
    this.passwordHash,
    required this.role,
    this.kelurahan,
    this.seksi,
    this.noHp,
    this.aktif = true,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String nama;
  final String email;
  final String? passwordHash;
  final String role;
  final String? kelurahan;
  final String? seksi;
  final String? noHp;
  final bool aktif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: toIntValue(map['id']),
      nama: toStringValue(map['nama']),
      email: toStringValue(map['email']),
      passwordHash: toNullableString(map['password_hash']),
      role: toStringValue(map['role']),
      kelurahan: toNullableString(map['kelurahan']),
      seksi: toNullableString(map['seksi']),
      noHp: toNullableString(map['no_hp']),
      aktif: toBoolValue(map['aktif'], fallback: true),
      createdAt: toDateTimeValue(map['created_at']),
      updatedAt: toDateTimeValue(map['updated_at']),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  bool get isKasubag => role == 'kasubag';
  bool get isCamat => role == 'camat';
  bool get isSeksi => role == 'seksi';
  bool get isWarga => role == 'warga';

  Map<String, dynamic> toDatabaseMap({
    bool includeId = false,
    bool includePassword = false,
  }) {
    return {
      if (includeId && id != null) 'id': id,
      'nama': nama.trim(),
      'email': email.trim().toLowerCase(),
      if (includePassword && passwordHash != null)
        'password_hash': passwordHash,
      'role': role,
      'kelurahan': kelurahan,
      'seksi': seksi,
      'no_hp': noHp,
      'aktif': aktif ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'kelurahan': kelurahan,
      'seksi': seksi,
      'no_hp': noHp,
      'aktif': aktif,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
