import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/time_off_balance_entity.dart';
import '../../domain/entities/time_off_policy_entity.dart';
import '../../domain/entities/time_off_request_entity.dart';
import '../../domain/repositories/time_off_repository.dart';
import '../datasources/time_off_remote_datasource.dart';
import '../models/time_off_policy_model.dart';
import '../models/time_off_request_model.dart';

class TimeOffRepositoryImpl implements TimeOffRepository {
  final TimeOffRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TimeOffRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

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
  Future<Either<Failure, TimeOffRequestEntity>> requestTimeOff(TimeOffRequestEntity request) =>
      _guard(() => remoteDataSource.requestTimeOff(TimeOffRequestModel.fromEntity(request)));

  @override
  Future<Either<Failure, void>> cancelTimeOff(String requestId) =>
      _guard(() => remoteDataSource.cancelTimeOff(requestId));

  @override
  Future<Either<Failure, TimeOffRequestEntity>> approveTimeOff({
    required String requestId,
    String? note,
  }) =>
      _guard(() => remoteDataSource.approveTimeOff(requestId: requestId, note: note));

  @override
  Future<Either<Failure, TimeOffRequestEntity>> rejectTimeOff({
    required String requestId,
    String? note,
  }) =>
      _guard(() => remoteDataSource.rejectTimeOff(requestId: requestId, note: note));

  @override
  Future<Either<Failure, List<TimeOffRequestEntity>>> getMyRequests() =>
      _guard(() => remoteDataSource.getMyRequests());

  @override
  Future<Either<Failure, List<TimeOffRequestEntity>>> getTeamRequests() =>
      _guard(() => remoteDataSource.getTeamRequests());

  @override
  Future<Either<Failure, List<TimeOffBalanceEntity>>> getMyBalances() =>
      _guard(() => remoteDataSource.getMyBalances());

  @override
  Future<Either<Failure, List<TimeOffPolicyEntity>>> getPolicies() =>
      _guard(() => remoteDataSource.getPolicies());

  @override
  Future<Either<Failure, TimeOffPolicyEntity>> updatePolicy(TimeOffPolicyEntity policy) =>
      _guard(() => remoteDataSource.updatePolicy(TimeOffPolicyModel.fromEntity(policy)));
}
