part of 'attendance_bloc.dart';

enum AttendanceStatusFlag { initial, loading, loaded, actionInProgress, failure }

class AttendanceState extends Equatable {
  final AttendanceStatusFlag status;
  final List<AttendanceEntity> myAttendance;
  final List<AttendanceEntity> teamAttendance;
  final AttendanceEntity? todayRecord; // today's clock-in/out for the current user
  final String? errorMessage;

  const AttendanceState({
    this.status = AttendanceStatusFlag.initial,
    this.myAttendance = const [],
    this.teamAttendance = const [],
    this.todayRecord,
    this.errorMessage,
  });

  bool get isClockedInNow => todayRecord?.isClockedIn ?? false;

  AttendanceState copyWith({
    AttendanceStatusFlag? status,
    List<AttendanceEntity>? myAttendance,
    List<AttendanceEntity>? teamAttendance,
    AttendanceEntity? todayRecord,
    String? errorMessage,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      myAttendance: myAttendance ?? this.myAttendance,
      teamAttendance: teamAttendance ?? this.teamAttendance,
      todayRecord: todayRecord ?? this.todayRecord,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, myAttendance, teamAttendance, todayRecord, errorMessage];
}
