import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/stream_usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';
import 'get_my_attendance_usecase.dart'; // reuses DateRangeParams

class WatchMyAttendanceUseCase implements StreamUseCase<List<AttendanceEntity>, DateRangeParams> {
  final AttendanceRepository repository;
  WatchMyAttendanceUseCase(this.repository);

  @override
  Stream<Either<Failure, List<AttendanceEntity>>> call(DateRangeParams params) {
    return repository.watchMyAttendance(from: params.from, to: params.to);
  }
}
