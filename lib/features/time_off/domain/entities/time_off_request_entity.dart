import 'package:equatable/equatable.dart';

enum TimeOffType { vacation, sick, personal, unpaid, bereavement, other }

enum TimeOffStatus { pending, approved, rejected, cancelled }

class TimeOffRequestEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final TimeOffType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final TimeOffStatus status;
  final String? approverId;
  final String? approverName;
  final String? decisionNote;
  final DateTime createdAt;

  const TimeOffRequestEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.status = TimeOffStatus.pending,
    this.approverId,
    this.approverName,
    this.decisionNote,
    required this.createdAt,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;
  bool get isPending => status == TimeOffStatus.pending;
  bool get canBeCancelledByOwner => status == TimeOffStatus.pending;

  TimeOffRequestEntity copyWith({
    TimeOffStatus? status,
    String? approverId,
    String? approverName,
    String? decisionNote,
  }) {
    return TimeOffRequestEntity(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      decisionNote: decisionNote ?? this.decisionNote,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        type,
        startDate,
        endDate,
        reason,
        status,
        approverId,
        approverName,
        decisionNote,
        createdAt,
      ];
}
