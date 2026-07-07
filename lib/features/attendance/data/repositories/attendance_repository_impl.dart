import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/working_hours_settings_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';
import '../models/working_hours_settings_model.dart';

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

  @override
  Stream<Either<Failure, List<AttendanceEntity>>> watchMyAttendance({
    required DateTime from,
    required DateTime to,
  }) {
    return remoteDataSource.watchMyAttendance(from: from, to: to).transform(
      StreamTransformer<List<AttendanceModel>, Either<Failure, List<AttendanceEntity>>>.fromHandlers(
        handleData: (data, sink) => sink.add(Right(data)),
        handleError: (error, stackTrace, sink) {
          if (error is AuthException) {
            sink.add(Left(PermissionFailure(error.message)));
          } else if (error is ServerException) {
            sink.add(Left(ServerFailure(error.message)));
          } else {
            sink.add(Left(UnknownFailure(error.toString())));
          }
        },
      ),
    );
  }

  @override
  Future<Either<Failure, WorkingHoursSettingsEntity>> getWorkingHoursSettings() =>
      _guard(() => remoteDataSource.getWorkingHoursSettings());

  @override
  Future<Either<Failure, WorkingHoursSettingsEntity>> updateWorkingHoursSettings(
          WorkingHoursSettingsEntity settings) =>
      _guard(() =>
          remoteDataSource.updateWorkingHoursSettings(WorkingHoursSettingsModel.fromEntity(settings)));
}
