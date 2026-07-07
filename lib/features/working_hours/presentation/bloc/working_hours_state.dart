part of 'working_hours_bloc.dart';

enum WorkingHoursStatusFlag { initial, loading, loaded, actionInProgress, actionSuccess, failure }

class WorkingHoursState extends Equatable {
  final WorkingHoursStatusFlag status;
  final List<WorkingHoursPolicyEntity> policies;
  final List<WorkingHoursAssignmentEntity> assignments;
  final String? errorMessage;

  const WorkingHoursState({
    this.status = WorkingHoursStatusFlag.initial,
    this.policies = const [],
    this.assignments = const [],
    this.errorMessage,
  });

  List<WorkingHoursAssignmentEntity> get activeOrUpcoming =>
      assignments.where((a) => !a.isPast).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

  List<WorkingHoursAssignmentEntity> get history =>
      assignments.where((a) => a.isPast).toList()..sort((a, b) => b.endDate.compareTo(a.endDate));

  WorkingHoursState copyWith({
    WorkingHoursStatusFlag? status,
    List<WorkingHoursPolicyEntity>? policies,
    List<WorkingHoursAssignmentEntity>? assignments,
    String? errorMessage,
  }) {
    return WorkingHoursState(
      status: status ?? this.status,
      policies: policies ?? this.policies,
      assignments: assignments ?? this.assignments,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, policies, assignments, errorMessage];
}
