part of 'employee_bloc.dart';

enum EmployeeStatusFlag { initial, loading, loaded, actionInProgress, actionSuccess, failure }

class EmployeeState extends Equatable {
  final EmployeeStatusFlag status;
  final List<EmployeeEntity> teamMembers;
  final List<EmployeeEntity> allEmployees;
  final EmployeeEntity? selectedEmployee;
  final String? errorMessage;

  const EmployeeState({
    this.status = EmployeeStatusFlag.initial,
    this.teamMembers = const [],
    this.allEmployees = const [],
    this.selectedEmployee,
    this.errorMessage,
  });

  EmployeeState copyWith({
    EmployeeStatusFlag? status,
    List<EmployeeEntity>? teamMembers,
    List<EmployeeEntity>? allEmployees,
    EmployeeEntity? selectedEmployee,
    String? errorMessage,
  }) {
    return EmployeeState(
      status: status ?? this.status,
      teamMembers: teamMembers ?? this.teamMembers,
      allEmployees: allEmployees ?? this.allEmployees,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, teamMembers, allEmployees, selectedEmployee, errorMessage];
}
