part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

/// Loads the logged-in user's own attendance history (last 30 days by default).
class MyAttendanceRequested extends AttendanceEvent {
  const MyAttendanceRequested();
}

class ClockInRequested extends AttendanceEvent {
  final String? note;
  const ClockInRequested({this.note});
  @override
  List<Object?> get props => [note];
}

class ClockOutRequested extends AttendanceEvent {
  final String? note;
  const ClockOutRequested({this.note});
  @override
  List<Object?> get props => [note];
}

/// Admin/Super Admin only — UI should only dispatch this when
/// Permissions.canViewTeamAttendance is true.
class TeamAttendanceRequested extends AttendanceEvent {
  final DateTime from;
  final DateTime to;
  const TeamAttendanceRequested({required this.from, required this.to});
  @override
  List<Object?> get props => [from, to];
}

class AttendanceRecordUpdateRequested extends AttendanceEvent {
  final AttendanceEntity record;
  const AttendanceRecordUpdateRequested(this.record);
  @override
  List<Object?> get props => [record];
}
