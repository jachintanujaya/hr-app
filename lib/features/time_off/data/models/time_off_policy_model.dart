import '../../domain/entities/time_off_policy_entity.dart';
import '../../domain/entities/time_off_request_entity.dart';

class TimeOffPolicyModel extends TimeOffPolicyEntity {
  const TimeOffPolicyModel({
    required super.id,
    required super.type,
    required super.annualAllowanceDays,
    super.requiresApproval = true,
    super.minNoticeDays = 0,
    super.carriesOverToNextYear = false,
  });

  factory TimeOffPolicyModel.fromJson(Map<String, dynamic> json) {
    return TimeOffPolicyModel(
      id: json['id'] as String,
      type: TimeOffType.values.firstWhere(
        (t) => t.name.toLowerCase() == (json['type'] as String? ?? 'other').toLowerCase(),
        orElse: () => TimeOffType.other,
      ),
      annualAllowanceDays: (json['annual_allowance_days'] as num).toDouble(),
      requiresApproval: json['requires_approval'] as bool? ?? true,
      minNoticeDays: json['min_notice_days'] as int? ?? 0,
      carriesOverToNextYear: json['carries_over_to_next_year'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'annual_allowance_days': annualAllowanceDays,
      'requires_approval': requiresApproval,
      'min_notice_days': minNoticeDays,
      'carries_over_to_next_year': carriesOverToNextYear,
    };
  }

  factory TimeOffPolicyModel.fromEntity(TimeOffPolicyEntity e) {
    return TimeOffPolicyModel(
      id: e.id,
      type: e.type,
      annualAllowanceDays: e.annualAllowanceDays,
      requiresApproval: e.requiresApproval,
      minNoticeDays: e.minNoticeDays,
      carriesOverToNextYear: e.carriesOverToNextYear,
    );
  }
}
