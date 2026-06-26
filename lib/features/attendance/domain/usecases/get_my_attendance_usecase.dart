import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMyAttendanceUseCase implements UseCase<List<AttendanceEntity>, DateRangeParams> {
  final AttendanceRepository repository;
  GetMyAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, List<AttendanceEntity>>> call(DateRangeParams params) {
    return repository.getMyAttendance(from: params.from, to: params.to);
  }
}

class DateRangeParams extends Equatable {
  final DateTime from;
  final DateTime to;
  const DateRangeParams({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}
