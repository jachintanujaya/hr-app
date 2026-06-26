import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class ClockOutUseCase implements UseCase<AttendanceEntity, ClockOutParams> {
  final AttendanceRepository repository;
  ClockOutUseCase(this.repository);

  @override
  Future<Either<Failure, AttendanceEntity>> call(ClockOutParams params) {
    return repository.clockOut(note: params.note);
  }
}

class ClockOutParams {
  final String? note;
  const ClockOutParams({this.note});
}
