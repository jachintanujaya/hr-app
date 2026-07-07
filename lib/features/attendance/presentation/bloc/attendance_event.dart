part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

/// Loads the logged-in user's own attendance history (last 30 days),
/// used by the dashboard's working-hours card.
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

/// Admin/Super Admin only.
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

/// Switches the attendance-history table to a given month and subscribes
/// to a live Firestore stream for that range. Any date within the target
/// month works; the bloc normalizes to the first/last day.
class MyAttendanceMonthChanged extends AttendanceEvent {
  final DateTime month;
  const MyAttendanceMonthChanged(this.month);
  @override
  List<Object?> get props => [month];
}

class WorkingHoursSettingsRequested extends AttendanceEvent {
  const WorkingHoursSettingsRequested();
}

/// Super Admin only.
class WorkingHoursSettingsUpdateRequested extends AttendanceEvent {
  final WorkingHoursSettingsEntity settings;
  const WorkingHoursSettingsUpdateRequested(this.settings);
  @override
  List<Object?> get props => [settings];
}
