import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/working_hours_assignment_entity.dart';
import '../../domain/entities/working_hours_policy_entity.dart';
import '../../domain/usecases/assign_policy_usecase.dart';
import '../../domain/usecases/create_policy_usecase.dart';
import '../../domain/usecases/watch_assignments_for_policy_usecase.dart';
import '../../domain/usecases/watch_policies_usecase.dart';

part 'working_hours_event.dart';
part 'working_hours_state.dart';

class WorkingHoursBloc extends Bloc<WorkingHoursEvent, WorkingHoursState> {
  final WatchPoliciesUseCase watchPoliciesUseCase;
  final CreatePolicyUseCase createPolicyUseCase;
  final WatchAssignmentsForPolicyUseCase watchAssignmentsForPolicyUseCase;
  final AssignPolicyUseCase assignPolicyUseCase;

  WorkingHoursBloc({
    required this.watchPoliciesUseCase,
    required this.createPolicyUseCase,
    required this.watchAssignmentsForPolicyUseCase,
    required this.assignPolicyUseCase,
  }) : super(const WorkingHoursState()) {
    on<PoliciesWatchStarted>(_onPoliciesWatchStarted, transformer: restartable());
    on<PolicyCreateRequested>(_onPolicyCreateRequested);
    on<AssignmentsWatchStarted>(_onAssignmentsWatchStarted, transformer: restartable());
    on<PolicyAssignRequested>(_onPolicyAssignRequested);
  }

  Future<void> _onPoliciesWatchStarted(
    PoliciesWatchStarted event,
    Emitter<WorkingHoursState> emit,
  ) async {
    emit(state.copyWith(status: WorkingHoursStatusFlag.loading));
    await emit.onEach(
      watchPoliciesUseCase(NoParams()),
      onData: (result) => result.fold(
        (failure) =>
            emit(state.copyWith(status: WorkingHoursStatusFlag.failure, errorMessage: failure.message)),
        (policies) => emit(state.copyWith(status: WorkingHoursStatusFlag.loaded, policies: policies)),
      ),
    );
  }

  Future<void> _onPolicyCreateRequested(
    PolicyCreateRequested event,
    Emitter<WorkingHoursState> emit,
  ) async {
    emit(state.copyWith(status: WorkingHoursStatusFlag.actionInProgress));
    final result = await createPolicyUseCase(event.policy);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: WorkingHoursStatusFlag.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: WorkingHoursStatusFlag.actionSuccess)),
    );
  }

  Future<void> _onAssignmentsWatchStarted(
    AssignmentsWatchStarted event,
    Emitter<WorkingHoursState> emit,
  ) async {
    await emit.onEach(
      watchAssignmentsForPolicyUseCase(event.policyId),
      onData: (result) => result.fold(
        (failure) =>
            emit(state.copyWith(status: WorkingHoursStatusFlag.failure, errorMessage: failure.message)),
        (assignments) => emit(state.copyWith(assignments: assignments)),
      ),
    );
  }

  Future<void> _onPolicyAssignRequested(
    PolicyAssignRequested event,
    Emitter<WorkingHoursState> emit,
  ) async {
    emit(state.copyWith(status: WorkingHoursStatusFlag.actionInProgress));
    final result = await assignPolicyUseCase(AssignPolicyParams(
      policy: event.policy,
      employees: event.employees,
      start: event.start,
      end: event.end,
    ));
    result.fold(
      (failure) =>
          emit(state.copyWith(status: WorkingHoursStatusFlag.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: WorkingHoursStatusFlag.actionSuccess)),
    );
  }
}
