import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/working_hours_assignment_entity.dart';

class WorkingHoursAssignmentModel extends WorkingHoursAssignmentEntity {
  const WorkingHoursAssignmentModel({
    required super.id,
    required super.policyId,
    required super.policyName,
    required super.employeeId,
    required super.employeeName,
    required super.startDate,
    required super.endDate,
    super.createdAt,
  });

  factory WorkingHoursAssignmentModel.fromFirestore(String id, Map<String, dynamic> data) {
    return WorkingHoursAssignmentModel(
      id: id,
      policyId: data['policy_id'] as String? ?? '',
      policyName: data['policy_name'] as String? ?? '',
      employeeId: data['employee_id'] as String? ?? '',
      employeeName: data['employee_name'] as String? ?? '',
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policy_id': policyId,
      'policy_name': policyName,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
    };
  }
}
