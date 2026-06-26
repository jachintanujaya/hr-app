import '../../domain/entities/time_off_balance_entity.dart';
import '../../domain/entities/time_off_request_entity.dart';

class TimeOffBalanceModel extends TimeOffBalanceEntity {
  const TimeOffBalanceModel({
    required super.type,
    required super.totalDays,
    required super.usedDays,
  });

  factory TimeOffBalanceModel.fromJson(Map<String, dynamic> json) {
    return TimeOffBalanceModel(
      type: TimeOffType.values.firstWhere(
        (t) => t.name.toLowerCase() == (json['type'] as String? ?? 'other').toLowerCase(),
        orElse: () => TimeOffType.other,
      ),
      totalDays: (json['total_days'] as num).toDouble(),
      usedDays: (json['used_days'] as num).toDouble(),
    );
  }
}
