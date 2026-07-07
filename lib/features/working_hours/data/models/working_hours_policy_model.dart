import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/working_hours_policy_entity.dart';

class WorkingHoursPolicyModel extends WorkingHoursPolicyEntity {
  const WorkingHoursPolicyModel({
    required super.id,
    required super.name,
    required super.startTime,
    required super.endTime,
    required super.standardHoursPerDay,
    super.createdAt,
  });

  factory WorkingHoursPolicyModel.fromFirestore(String id, Map<String, dynamic> data) {
    return WorkingHoursPolicyModel(
      id: id,
      name: data['name'] as String? ?? '',
      startTime: data['start_time'] as String? ?? '09:00',
      endTime: data['end_time'] as String? ?? '17:00',
      standardHoursPerDay: (data['standard_hours_per_day'] as num?)?.toDouble() ?? 8,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'standard_hours_per_day': standardHoursPerDay,
    };
  }
}
