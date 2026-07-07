import 'package:equatable/equatable.dart';

/// A named working-hours template (e.g. "WFO", "WFC") that can be assigned
/// to employees for a date range. Super Admin only.
class WorkingHoursPolicyEntity extends Equatable {
  final String id;
  final String name;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final double standardHoursPerDay;
  final DateTime? createdAt;

  const WorkingHoursPolicyEntity({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.standardHoursPerDay,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, startTime, endTime, standardHoursPerDay, createdAt];
}
