part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
  @override
  List<Object?> get props => [];
}

/// Admin & Super Admin — employees reporting to the current admin.
class TeamMembersRequested extends EmployeeEvent {
  const TeamMembersRequested();
}

/// Super Admin only — everyone in the org, optionally filtered.
class AllEmployeesRequested extends EmployeeEvent {
  final String? searchQuery;
  const AllEmployeesRequested({this.searchQuery});
  @override
  List<Object?> get props => [searchQuery];
}

class EmployeeDetailRequested extends EmployeeEvent {
  final String employeeId;
  const EmployeeDetailRequested(this.employeeId);
  @override
  List<Object?> get props => [employeeId];
}

/// Super Admin only.
class EmployeeCreateRequested extends EmployeeEvent {
  final EmployeeEntity employee;
  const EmployeeCreateRequested(this.employee);
  @override
  List<Object?> get props => [employee];
}

class EmployeeUpdateRequested extends EmployeeEvent {
  final EmployeeEntity employee;
  const EmployeeUpdateRequested(this.employee);
  @override
  List<Object?> get props => [employee];
}

/// Super Admin only.
class EmployeeDeleteRequested extends EmployeeEvent {
  final String employeeId;
  const EmployeeDeleteRequested(this.employeeId);
  @override
  List<Object?> get props => [employeeId];
}

/// Super Admin only — promote/demote or move under a different manager.
class EmployeeReassignRequested extends EmployeeEvent {
  final String employeeId;
  final String? newRole;
  final String? newManagerId;
  const EmployeeReassignRequested({required this.employeeId, this.newRole, this.newManagerId});
  @override
  List<Object?> get props => [employeeId, newRole, newManagerId];
}
