import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_settings_entity.dart';
import '../repositories/attendance_repository.dart';

class GetWorkingHoursSettingsUseCase implements UseCase<WorkingHoursSettingsEntity, NoParams> {
  final AttendanceRepository repository;
  GetWorkingHoursSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursSettingsEntity>> call(NoParams params) {
    return repository.getWorkingHoursSettings();
  }
}
