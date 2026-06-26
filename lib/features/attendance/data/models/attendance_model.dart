import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.date,
    super.clockInTime,
    super.clockOutTime,
    required super.status,
    super.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      clockInTime:
          json['clock_in_time'] != null ? DateTime.parse(json['clock_in_time'] as String) : null,
      clockOutTime:
          json['clock_out_time'] != null ? DateTime.parse(json['clock_out_time'] as String) : null,
      status: _statusFromString(json['status'] as String? ?? 'present'),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'date': date.toIso8601String(),
      'clock_in_time': clockInTime?.toIso8601String(),
      'clock_out_time': clockOutTime?.toIso8601String(),
      'status': status.name,
      'note': note,
    };
  }

  static AttendanceStatus _statusFromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AttendanceStatus.present,
    );
  }

  factory AttendanceModel.fromEntity(AttendanceEntity e) {
    return AttendanceModel(
      id: e.id,
      employeeId: e.employeeId,
      employeeName: e.employeeName,
      date: e.date,
      clockInTime: e.clockInTime,
      clockOutTime: e.clockOutTime,
      status: e.status,
      note: e.note,
    );
  }
}
