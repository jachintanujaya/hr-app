import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, late, absent, onLeave, halfDay }

class AttendanceEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final AttendanceStatus status;
  final String? note;

  const AttendanceEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.status,
    this.note,
  });

  bool get isClockedIn => clockInTime != null && clockOutTime == null;
  bool get isComplete => clockInTime != null && clockOutTime != null;

  Duration? get workedDuration {
    if (clockInTime == null || clockOutTime == null) return null;
    return clockOutTime!.difference(clockInTime!);
  }

  AttendanceEntity copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    AttendanceStatus? status,
    String? note,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props =>
      [id, employeeId, employeeName, date, clockInTime, clockOutTime, status, note];
}
