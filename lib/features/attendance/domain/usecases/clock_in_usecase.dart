import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class ClockInUseCase implements UseCase<AttendanceEntity, ClockInParams> {
  final AttendanceRepository repository;
  ClockInUseCase(this.repository);

  @override
  Future<Either<Failure, AttendanceEntity>> call(ClockInParams params) {
    return repository.clockIn(note: params.note);
  }
}

class ClockInParams {
  final String? note;
  const ClockInParams({this.note});
}
