part of 'working_hours_bloc.dart';

abstract class WorkingHoursEvent extends Equatable {
  const WorkingHoursEvent();
  @override
  List<Object?> get props => [];
}

class PoliciesWatchStarted extends WorkingHoursEvent {
  const PoliciesWatchStarted();
}

class PolicyCreateRequested extends WorkingHoursEvent {
  final WorkingHoursPolicyEntity policy;
  const PolicyCreateRequested(this.policy);
  @override
  List<Object?> get props => [policy];
}

class AssignmentsWatchStarted extends WorkingHoursEvent {
  final String policyId;
  const AssignmentsWatchStarted(this.policyId);
  @override
  List<Object?> get props => [policyId];
}

class PolicyAssignRequested extends WorkingHoursEvent {
  final WorkingHoursPolicyEntity policy;
  final Map<String, String> employees;
  final DateTime start;
  final DateTime end;
  const PolicyAssignRequested({
    required this.policy,
    required this.employees,
    required this.start,
    required this.end,
  });
  @override
  List<Object?> get props => [policy, employees, start, end];
}
