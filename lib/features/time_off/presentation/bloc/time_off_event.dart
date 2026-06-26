part of 'time_off_bloc.dart';

abstract class TimeOffEvent extends Equatable {
  const TimeOffEvent();
  @override
  List<Object?> get props => [];
}

/// Loads the logged-in user's own requests + balances.
class MyTimeOffRequested extends TimeOffEvent {
  const MyTimeOffRequested();
}

class TimeOffRequestSubmitted extends TimeOffEvent {
  final TimeOffRequestEntity request;
  const TimeOffRequestSubmitted(this.request);
  @override
  List<Object?> get props => [request];
}

class TimeOffCancelRequested extends TimeOffEvent {
  final String requestId;
  const TimeOffCancelRequested(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

/// Admin/Super Admin only.
class TeamTimeOffRequested extends TimeOffEvent {
  const TeamTimeOffRequested();
}

/// Admin/Super Admin only.
class TimeOffApproveRequested extends TimeOffEvent {
  final String requestId;
  final String? note;
  const TimeOffApproveRequested(this.requestId, {this.note});
  @override
  List<Object?> get props => [requestId, note];
}

/// Admin/Super Admin only.
class TimeOffRejectRequested extends TimeOffEvent {
  final String requestId;
  final String? note;
  const TimeOffRejectRequested(this.requestId, {this.note});
  @override
  List<Object?> get props => [requestId, note];
}

/// Super Admin only.
class PoliciesRequested extends TimeOffEvent {
  const PoliciesRequested();
}

/// Super Admin only.
class PolicyUpdateRequested extends TimeOffEvent {
  final TimeOffPolicyEntity policy;
  const PolicyUpdateRequested(this.policy);
  @override
  List<Object?> get props => [policy];
}
