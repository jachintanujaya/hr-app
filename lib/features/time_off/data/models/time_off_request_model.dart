import '../../domain/entities/time_off_request_entity.dart';

class TimeOffRequestModel extends TimeOffRequestEntity {
  const TimeOffRequestModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.type,
    required super.startDate,
    required super.endDate,
    super.reason,
    super.status = TimeOffStatus.pending,
    super.approverId,
    super.approverName,
    super.decisionNote,
    required super.createdAt,
  });

  factory TimeOffRequestModel.fromJson(Map<String, dynamic> json) {
    return TimeOffRequestModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String? ?? '',
      type: _typeFromString(json['type'] as String? ?? 'other'),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String?,
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      approverId: json['approver_id'] as String?,
      approverName: json['approver_name'] as String?,
      decisionNote: json['decision_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status.name,
      'approver_id': approverId,
      'decision_note': decisionNote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static TimeOffType _typeFromString(String value) {
    return TimeOffType.values.firstWhere(
      (t) => t.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TimeOffType.other,
    );
  }

  static TimeOffStatus _statusFromString(String value) {
    return TimeOffStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TimeOffStatus.pending,
    );
  }

  factory TimeOffRequestModel.fromEntity(TimeOffRequestEntity e) {
    return TimeOffRequestModel(
      id: e.id,
      employeeId: e.employeeId,
      employeeName: e.employeeName,
      type: e.type,
      startDate: e.startDate,
      endDate: e.endDate,
      reason: e.reason,
      status: e.status,
      approverId: e.approverId,
      approverName: e.approverName,
      decisionNote: e.decisionNote,
      createdAt: e.createdAt,
    );
  }
}
