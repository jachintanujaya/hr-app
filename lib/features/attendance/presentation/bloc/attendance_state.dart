part of 'attendance_bloc.dart';

enum AttendanceStatusFlag { initial, loading, loaded, actionInProgress, actionSuccess, failure }

class AttendanceState extends Equatable {
  final AttendanceStatusFlag status;
  final List<AttendanceEntity> myAttendance;
  final List<AttendanceEntity> teamAttendance;
  final AttendanceEntity? todayRecord;
  final DateTime? selectedMonth;
  final WorkingHoursSettingsEntity? workingHoursSettings;
  final String? errorMessage;

  const AttendanceState({
    this.status = AttendanceStatusFlag.initial,
    this.myAttendance = const [],
    this.teamAttendance = const [],
    this.todayRecord,
    this.selectedMonth,
    this.workingHoursSettings,
    this.errorMessage,
  });

  bool get isClockedInNow => todayRecord?.isClockedIn ?? false;

  AttendanceState copyWith({
    AttendanceStatusFlag? status,
    List<AttendanceEntity>? myAttendance,
    List<AttendanceEntity>? teamAttendance,
    AttendanceEntity? todayRecord,
    DateTime? selectedMonth,
    WorkingHoursSettingsEntity? workingHoursSettings,
    String? errorMessage,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      myAttendance: myAttendance ?? this.myAttendance,
      teamAttendance: teamAttendance ?? this.teamAttendance,
      todayRecord: todayRecord ?? this.todayRecord,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      workingHoursSettings: workingHoursSettings ?? this.workingHoursSettings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        myAttendance,
        teamAttendance,
        todayRecord,
        selectedMonth,
        workingHoursSettings,
        errorMessage,
      ];
}
