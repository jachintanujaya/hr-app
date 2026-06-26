import 'package:equatable/equatable.dart';
import 'time_off_request_entity.dart';

class TimeOffBalanceEntity extends Equatable {
  final TimeOffType type;
  final double totalDays;
  final double usedDays;

  const TimeOffBalanceEntity({
    required this.type,
    required this.totalDays,
    required this.usedDays,
  });

  double get remainingDays => totalDays - usedDays;

  @override
  List<Object?> get props => [type, totalDays, usedDays];
}
