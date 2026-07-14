import '_model_value.dart';

class ClusterRunModel {
  const ClusterRunModel({
    this.id,
    required this.kValue,
    required this.jumlahData,
    required this.silhouette,
    required this.createdBy,
    this.createdAt,
  });

  final int? id;
  final int kValue;
  final int jumlahData;
  final double silhouette;
  final int createdBy;
  final DateTime? createdAt;

  factory ClusterRunModel.fromMap(Map<String, dynamic> map) {
    return ClusterRunModel(
      id: toIntValue(map['id']),
      kValue: toIntValue(map['k_value']) ?? 0,
      jumlahData: toIntValue(map['jumlah_data']) ?? 0,
      silhouette: toDoubleValue(map['silhouette']) ?? 0,
      createdBy: toIntValue(map['created_by']) ?? 0,
      createdAt: toDateTimeValue(map['created_at']),
    );
  }

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'k_value': kValue,
      'jumlah_data': jumlahData,
      'silhouette': silhouette,
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      ...toDatabaseMap(includeId: true),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ClusterMemberModel {
  const ClusterMemberModel({
    this.id,
    required this.runId,
    required this.suratId,
    required this.clusterNo,
    required this.clusterLabel,
    required this.distance,
  });

  final int? id;
  final int runId;
  final int suratId;
  final int clusterNo;
  final String clusterLabel;
  final double distance;

  factory ClusterMemberModel.fromMap(Map<String, dynamic> map) {
    return ClusterMemberModel(
      id: toIntValue(map['id']),
      runId: toIntValue(map['run_id']) ?? 0,
      suratId: toIntValue(map['surat_id']) ?? 0,
      clusterNo: toIntValue(map['cluster_no']) ?? 0,
      clusterLabel: toStringValue(map['cluster_label']),
      distance: toDoubleValue(map['distance']) ?? 0,
    );
  }

  Map<String, dynamic> toDatabaseMap({bool includeId = false}) {
    return {
      if (includeId && id != null) 'id': id,
      'run_id': runId,
      'surat_id': suratId,
      'cluster_no': clusterNo,
      'cluster_label': clusterLabel,
      'distance': distance,
    };
  }

  Map<String, dynamic> toJson() {
    return toDatabaseMap(includeId: true);
  }
}
