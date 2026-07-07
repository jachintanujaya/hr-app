import '../../domain/entities/working_hours_settings_entity.dart';

class WorkingHoursSettingsModel extends WorkingHoursSettingsEntity {
  const WorkingHoursSettingsModel({
    required super.standardHoursPerDay,
    required super.workStartTime,
    required super.workEndTime,
  });

  factory WorkingHoursSettingsModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursSettingsModel(
      standardHoursPerDay: (json['standard_hours_per_day'] as num?)?.toDouble() ?? 8,
      workStartTime: json['work_start_time'] as String? ?? '09:00',
      workEndTime: json['work_end_time'] as String? ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard_hours_per_day': standardHoursPerDay,
      'work_start_time': workStartTime,
      'work_end_time': workEndTime,
    };
  }

  factory WorkingHoursSettingsModel.fromEntity(WorkingHoursSettingsEntity e) {
    return WorkingHoursSettingsModel(
      standardHoursPerDay: e.standardHoursPerDay,
      workStartTime: e.workStartTime,
      workEndTime: e.workEndTime,
    );
  }
}
