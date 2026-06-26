import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/time_off_balance_entity.dart';
import '../../domain/entities/time_off_policy_entity.dart';
import '../../domain/entities/time_off_request_entity.dart';
import '../../domain/usecases/approve_time_off_usecase.dart';
import '../../domain/usecases/cancel_time_off_usecase.dart';
import '../../domain/usecases/get_my_balances_usecase.dart';
import '../../domain/usecases/get_my_requests_usecase.dart';
import '../../domain/usecases/get_policies_usecase.dart';
import '../../domain/usecases/get_team_requests_usecase.dart';
import '../../domain/usecases/reject_time_off_usecase.dart';
import '../../domain/usecases/request_time_off_usecase.dart';
import '../../domain/usecases/update_policy_usecase.dart';

part 'time_off_event.dart';
part 'time_off_state.dart';

/// Single bloc serving: the employee request/cancel flow, the admin
/// approve/reject flow, and the super-admin policy management flow.
/// The UI decides which events to dispatch based on Permissions.
class TimeOffBloc extends Bloc<TimeOffEvent, TimeOffState> {
  final RequestTimeOffUseCase requestTimeOffUseCase;
  final CancelTimeOffUseCase cancelTimeOffUseCase;
  final ApproveTimeOffUseCase approveTimeOffUseCase;
  final RejectTimeOffUseCase rejectTimeOffUseCase;
  final GetMyRequestsUseCase getMyRequestsUseCase;
  final GetTeamRequestsUseCase getTeamRequestsUseCase;
  final GetMyBalancesUseCase getMyBalancesUseCase;
  final GetPoliciesUseCase getPoliciesUseCase;
  final UpdatePolicyUseCase updatePolicyUseCase;

  TimeOffBloc({
    required this.requestTimeOffUseCase,
    required this.cancelTimeOffUseCase,
    required this.approveTimeOffUseCase,
    required this.rejectTimeOffUseCase,
    required this.getMyRequestsUseCase,
    required this.getTeamRequestsUseCase,
    required this.getMyBalancesUseCase,
    required this.getPoliciesUseCase,
    required this.updatePolicyUseCase,
  }) : super(const TimeOffState()) {
    on<MyTimeOffRequested>(_onMyTimeOffRequested);
    on<TimeOffRequestSubmitted>(_onRequestSubmitted);
    on<TimeOffCancelRequested>(_onCancelRequested);
    on<TeamTimeOffRequested>(_onTeamRequested);
    on<TimeOffApproveRequested>(_onApproveRequested);
    on<TimeOffRejectRequested>(_onRejectRequested);
    on<PoliciesRequested>(_onPoliciesRequested);
    on<PolicyUpdateRequested>(_onPolicyUpdateRequested);
  }

  Future<void> _onMyTimeOffRequested(
    MyTimeOffRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.loading));
    final requestsResult = await getMyRequestsUseCase(NoParams());
    final balancesResult = await getMyBalancesUseCase(NoParams());

    if (requestsResult.isLeft()) {
      emit(state.copyWith(
        status: TimeOffStatusFlag.failure,
        errorMessage: requestsResult.fold((f) => f.message, (_) => null),
      ));
      return;
    }

    emit(state.copyWith(
      status: TimeOffStatusFlag.loaded,
      myRequests: requestsResult.fold((_) => [], (r) => r),
      myBalances: balancesResult.fold((_) => state.myBalances, (b) => b),
    ));
  }

  Future<void> _onRequestSubmitted(
    TimeOffRequestSubmitted event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.actionInProgress));
    final result = await requestTimeOffUseCase(event.request);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (created) => emit(state.copyWith(
        status: TimeOffStatusFlag.actionSuccess,
        myRequests: [created, ...state.myRequests],
      )),
    );
  }

  Future<void> _onCancelRequested(
    TimeOffCancelRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.actionInProgress));
    final result = await cancelTimeOffUseCase(event.requestId);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(
        status: TimeOffStatusFlag.actionSuccess,
        myRequests: state.myRequests
            .map((r) => r.id == event.requestId ? r.copyWith(status: TimeOffStatus.cancelled) : r)
            .toList(),
      )),
    );
  }

  Future<void> _onTeamRequested(
    TeamTimeOffRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.loading));
    final result = await getTeamRequestsUseCase(NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (requests) =>
          emit(state.copyWith(status: TimeOffStatusFlag.loaded, teamRequests: requests)),
    );
  }

  Future<void> _onApproveRequested(
    TimeOffApproveRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.actionInProgress));
    final result =
        await approveTimeOffUseCase(DecisionParams(requestId: event.requestId, note: event.note));
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (updated) => emit(state.copyWith(
        status: TimeOffStatusFlag.actionSuccess,
        teamRequests: _replace(state.teamRequests, updated),
      )),
    );
  }

  Future<void> _onRejectRequested(
    TimeOffRejectRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.actionInProgress));
    final result =
        await rejectTimeOffUseCase(DecisionParams(requestId: event.requestId, note: event.note));
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (updated) => emit(state.copyWith(
        status: TimeOffStatusFlag.actionSuccess,
        teamRequests: _replace(state.teamRequests, updated),
      )),
    );
  }

  Future<void> _onPoliciesRequested(
    PoliciesRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.loading));
    final result = await getPoliciesUseCase(NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (policies) => emit(state.copyWith(status: TimeOffStatusFlag.loaded, policies: policies)),
    );
  }

  Future<void> _onPolicyUpdateRequested(
    PolicyUpdateRequested event,
    Emitter<TimeOffState> emit,
  ) async {
    emit(state.copyWith(status: TimeOffStatusFlag.actionInProgress));
    final result = await updatePolicyUseCase(event.policy);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: TimeOffStatusFlag.failure, errorMessage: failure.message)),
      (updated) => emit(state.copyWith(
        status: TimeOffStatusFlag.actionSuccess,
        policies: state.policies.map((p) => p.id == updated.id ? updated : p).toList(),
      )),
    );
  }

  List<TimeOffRequestEntity> _replace(
      List<TimeOffRequestEntity> list, TimeOffRequestEntity updated) {
    return list.map((r) => r.id == updated.id ? updated : r).toList();
  }
}
