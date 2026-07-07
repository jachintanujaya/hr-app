import 'package:equatable/equatable.dart';

/// Org-wide standard working hours, configured by Super Admin (HR).
/// Acts as the fallback target when an employee has no active
/// WorkingHoursPolicy assignment (see features/working_hours/).
class WorkingHoursSettingsEntity extends Equatable {
  final double standardHoursPerDay;
  final String workStartTime; // "HH:mm", 24-hour format
  final String workEndTime;   // "HH:mm", 24-hour format

  const WorkingHoursSettingsEntity({
    required this.standardHoursPerDay,
    required this.workStartTime,
    required this.workEndTime,
  });

  static const defaults = WorkingHoursSettingsEntity(
    standardHoursPerDay: 8,
    workStartTime: '09:00',
    workEndTime: '17:00',
  );

  @override
  List<Object?> get props => [standardHoursPerDay, workStartTime, workEndTime];
}
