import 'package:equatable/equatable.dart';
import 'time_off_request_entity.dart';

/// Super Admin (HR) configures these org-wide rules.
class TimeOffPolicyEntity extends Equatable {
  final String id;
  final TimeOffType type;
  final double annualAllowanceDays;
  final bool requiresApproval;
  final int minNoticeDays;
  final bool carriesOverToNextYear;

  const TimeOffPolicyEntity({
    required this.id,
    required this.type,
    required this.annualAllowanceDays,
    this.requiresApproval = true,
    this.minNoticeDays = 0,
    this.carriesOverToNextYear = false,
  });

  TimeOffPolicyEntity copyWith({
    double? annualAllowanceDays,
    bool? requiresApproval,
    int? minNoticeDays,
    bool? carriesOverToNextYear,
  }) {
    return TimeOffPolicyEntity(
      id: id,
      type: type,
      annualAllowanceDays: annualAllowanceDays ?? this.annualAllowanceDays,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      minNoticeDays: minNoticeDays ?? this.minNoticeDays,
      carriesOverToNextYear: carriesOverToNextYear ?? this.carriesOverToNextYear,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, annualAllowanceDays, requiresApproval, minNoticeDays, carriesOverToNextYear];
}
