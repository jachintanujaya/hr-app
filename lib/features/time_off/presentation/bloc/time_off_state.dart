part of 'time_off_bloc.dart';

enum TimeOffStatusFlag { initial, loading, loaded, actionInProgress, actionSuccess, failure }

class TimeOffState extends Equatable {
  final TimeOffStatusFlag status;
  final List<TimeOffRequestEntity> myRequests;
  final List<TimeOffBalanceEntity> myBalances;
  final List<TimeOffRequestEntity> teamRequests;
  final List<TimeOffPolicyEntity> policies;
  final String? errorMessage;

  const TimeOffState({
    this.status = TimeOffStatusFlag.initial,
    this.myRequests = const [],
    this.myBalances = const [],
    this.teamRequests = const [],
    this.policies = const [],
    this.errorMessage,
  });

  List<TimeOffRequestEntity> get pendingTeamRequests =>
      teamRequests.where((r) => r.isPending).toList();

  TimeOffState copyWith({
    TimeOffStatusFlag? status,
    List<TimeOffRequestEntity>? myRequests,
    List<TimeOffBalanceEntity>? myBalances,
    List<TimeOffRequestEntity>? teamRequests,
    List<TimeOffPolicyEntity>? policies,
    String? errorMessage,
  }) {
    return TimeOffState(
      status: status ?? this.status,
      myRequests: myRequests ?? this.myRequests,
      myBalances: myBalances ?? this.myBalances,
      teamRequests: teamRequests ?? this.teamRequests,
      policies: policies ?? this.policies,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, myRequests, myBalances, teamRequests, policies, errorMessage];
}
