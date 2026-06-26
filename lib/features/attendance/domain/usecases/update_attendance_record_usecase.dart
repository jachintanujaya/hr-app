import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class UpdateAttendanceRecordUseCase implements UseCase<AttendanceEntity, AttendanceEntity> {
  final AttendanceRepository repository;
  UpdateAttendanceRecordUseCase(this.repository);

  @override
  Future<Either<Failure, AttendanceEntity>> call(AttendanceEntity params) {
    return repository.updateAttendanceRecord(params);
  }
}
