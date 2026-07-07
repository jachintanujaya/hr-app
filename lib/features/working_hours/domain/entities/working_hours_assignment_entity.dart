import 'package:equatable/equatable.dart';

/// Assigns a [WorkingHoursPolicyEntity] to one employee for a date range.
/// One doc per employee, even when a Super Admin assigns to a group at once.
class WorkingHoursAssignmentEntity extends Equatable {
  final String id;
  final String policyId;
  final String policyName; // denormalized for display
  final String employeeId;
  final String employeeName; // denormalized for display
  final DateTime startDate; // date-only (midnight)
  final DateTime endDate;   // date-only (midnight)
  final DateTime? createdAt;

  const WorkingHoursAssignmentEntity({
    required this.id,
    required this.policyId,
    required this.policyName,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  });

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get isActiveToday => !_today.isBefore(startDate) && !_today.isAfter(endDate);
  bool get isUpcoming => startDate.isAfter(_today);
  bool get isPast => endDate.isBefore(_today);

  /// True if [otherStart]..[otherEnd] overlaps this assignment's range.
  bool overlaps(DateTime otherStart, DateTime otherEnd) {
    return !(endDate.isBefore(otherStart) || otherEnd.isBefore(startDate));
  }

  @override
  List<Object?> get props =>
      [id, policyId, policyName, employeeId, employeeName, startDate, endDate, createdAt];
}
