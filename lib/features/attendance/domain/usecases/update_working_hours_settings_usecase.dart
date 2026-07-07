import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_settings_entity.dart';
import '../repositories/attendance_repository.dart';

/// Super Admin only — gate the UI with Permissions.canManageWorkingHoursSettings;
/// Firestore rules also enforce it.
class UpdateWorkingHoursSettingsUseCase
    implements UseCase<WorkingHoursSettingsEntity, WorkingHoursSettingsEntity> {
  final AttendanceRepository repository;
  UpdateWorkingHoursSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursSettingsEntity>> call(WorkingHoursSettingsEntity params) {
    return repository.updateWorkingHoursSettings(params);
  }
}
