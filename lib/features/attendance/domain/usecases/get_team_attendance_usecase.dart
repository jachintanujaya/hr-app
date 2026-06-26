import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';
import 'get_my_attendance_usecase.dart';

/// Permission check (canViewTeamAttendance) is enforced in the UI/bloc layer
/// before this usecase is even dispatched, and the backend should also
/// enforce it server-side — never rely on the client alone.
class GetTeamAttendanceUseCase implements UseCase<List<AttendanceEntity>, DateRangeParams> {
  final AttendanceRepository repository;
  GetTeamAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, List<AttendanceEntity>>> call(DateRangeParams params) {
    return repository.getTeamAttendance(from: params.from, to: params.to);
  }
}
