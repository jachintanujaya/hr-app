import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> clockIn({String? note}) =>
      _guard(() => remoteDataSource.clockIn(note: note));

  @override
  Future<Either<Failure, AttendanceEntity>> clockOut({String? note}) =>
      _guard(() => remoteDataSource.clockOut(note: note));

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getMyAttendance({
    required DateTime from,
    required DateTime to,
  }) =>
      _guard(() => remoteDataSource.getMyAttendance(from: from, to: to));

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getTeamAttendance({
    required DateTime from,
    required DateTime to,
  }) =>
      _guard(() => remoteDataSource.getTeamAttendance(from: from, to: to));

  @override
  Future<Either<Failure, AttendanceEntity>> updateAttendanceRecord(AttendanceEntity record) =>
      _guard(() => remoteDataSource.updateAttendanceRecord(AttendanceModel.fromEntity(record)));
}
