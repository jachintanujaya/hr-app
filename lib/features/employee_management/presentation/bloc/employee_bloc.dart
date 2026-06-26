import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/usecases/create_employee_usecase.dart';
import '../../domain/usecases/delete_employee_usecase.dart';
import '../../domain/usecases/get_all_employees_usecase.dart';
import '../../domain/usecases/get_employee_by_id_usecase.dart';
import '../../domain/usecases/get_team_members_usecase.dart';
import '../../domain/usecases/reassign_role_or_manager_usecase.dart';
import '../../domain/usecases/update_employee_usecase.dart';
import '../../../../core/usecases/usecase.dart';

part 'employee_event.dart';
part 'employee_state.dart';

/// Single bloc serving the admin "my team" screen, the super-admin
/// "all employees" screen, and create/edit/delete/reassign flows.
/// The UI decides which events to dispatch based on Permissions — this
/// bloc trusts the backend to be the real enforcement point.
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetTeamMembersUseCase getTeamMembersUseCase;
  final GetAllEmployeesUseCase getAllEmployeesUseCase;
  final GetEmployeeByIdUseCase getEmployeeByIdUseCase;
  final CreateEmployeeUseCase createEmployeeUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;
  final DeleteEmployeeUseCase deleteEmployeeUseCase;
  final ReassignRoleOrManagerUseCase reassignRoleOrManagerUseCase;

  EmployeeBloc({
    required this.getTeamMembersUseCase,
    required this.getAllEmployeesUseCase,
    required this.getEmployeeByIdUseCase,
    required this.createEmployeeUseCase,
    required this.updateEmployeeUseCase,
    required this.deleteEmployeeUseCase,
    required this.reassignRoleOrManagerUseCase,
  }) : super(const EmployeeState()) {
    on<TeamMembersRequested>(_onTeamMembersRequested);
    on<AllEmployeesRequested>(_onAllEmployeesRequested);
    on<EmployeeDetailRequested>(_onEmployeeDetailRequested);
    on<EmployeeCreateRequested>(_onEmployeeCreateRequested);
    on<EmployeeUpdateRequested>(_onEmployeeUpdateRequested);
    on<EmployeeDeleteRequested>(_onEmployeeDeleteRequested);
    on<EmployeeReassignRequested>(_onEmployeeReassignRequested);
  }

  Future<void> _onTeamMembersRequested(
    TeamMembersRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.loading));
    final result = await getTeamMembersUseCase(NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (members) =>
          emit(state.copyWith(status: EmployeeStatusFlag.loaded, teamMembers: members)),
    );
  }

  Future<void> _onAllEmployeesRequested(
    AllEmployeesRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.loading));
    final result = await getAllEmployeesUseCase(SearchParams(query: event.searchQuery));
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (employees) =>
          emit(state.copyWith(status: EmployeeStatusFlag.loaded, allEmployees: employees)),
    );
  }

  Future<void> _onEmployeeDetailRequested(
    EmployeeDetailRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.loading));
    final result = await getEmployeeByIdUseCase(event.employeeId);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (employee) =>
          emit(state.copyWith(status: EmployeeStatusFlag.loaded, selectedEmployee: employee)),
    );
  }

  Future<void> _onEmployeeCreateRequested(
    EmployeeCreateRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.actionInProgress));
    final result = await createEmployeeUseCase(event.employee);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (created) => emit(state.copyWith(
        status: EmployeeStatusFlag.actionSuccess,
        allEmployees: [...state.allEmployees, created],
      )),
    );
  }

  Future<void> _onEmployeeUpdateRequested(
    EmployeeUpdateRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.actionInProgress));
    final result = await updateEmployeeUseCase(event.employee);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (updated) => emit(state.copyWith(
        status: EmployeeStatusFlag.actionSuccess,
        selectedEmployee: updated,
        teamMembers: _replace(state.teamMembers, updated),
        allEmployees: _replace(state.allEmployees, updated),
      )),
    );
  }

  Future<void> _onEmployeeDeleteRequested(
    EmployeeDeleteRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.actionInProgress));
    final result = await deleteEmployeeUseCase(event.employeeId);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        status: EmployeeStatusFlag.actionSuccess,
        allEmployees: state.allEmployees.where((e) => e.id != event.employeeId).toList(),
        teamMembers: state.teamMembers.where((e) => e.id != event.employeeId).toList(),
      )),
    );
  }

  Future<void> _onEmployeeReassignRequested(
    EmployeeReassignRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatusFlag.actionInProgress));
    final result = await reassignRoleOrManagerUseCase(ReassignParams(
      employeeId: event.employeeId,
      newRole: event.newRole,
      newManagerId: event.newManagerId,
    ));
    result.fold(
      (failure) =>
          emit(state.copyWith(status: EmployeeStatusFlag.failure, errorMessage: failure.message)),
      (updated) => emit(state.copyWith(
        status: EmployeeStatusFlag.actionSuccess,
        selectedEmployee: updated,
        teamMembers: _replace(state.teamMembers, updated),
        allEmployees: _replace(state.allEmployees, updated),
      )),
    );
  }

  List<EmployeeEntity> _replace(List<EmployeeEntity> list, EmployeeEntity updated) {
    return list.map((e) => e.id == updated.id ? updated : e).toList();
  }
}
