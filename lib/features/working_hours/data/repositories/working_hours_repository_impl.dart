import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/working_hours_assignment_entity.dart';
import '../../domain/entities/working_hours_policy_entity.dart';
import '../../domain/repositories/working_hours_repository.dart';
import '../datasources/working_hours_remote_datasource.dart';
import '../models/working_hours_policy_model.dart';

class WorkingHoursRepositoryImpl implements WorkingHoursRepository {
  final WorkingHoursRemoteDataSource remoteDataSource;
  WorkingHoursRepositoryImpl({required this.remoteDataSource});

  Stream<Either<Failure, T>> _guardStream<T>(Stream<T> stream) {
    return stream.transform(StreamTransformer<T, Either<Failure, T>>.fromHandlers(
      handleData: (data, sink) => sink.add(Right(data)),
      handleError: (error, stackTrace, sink) => sink.add(Left(UnknownFailure(error.toString()))),
    ));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<WorkingHoursPolicyEntity>>> watchPolicies() =>
      _guardStream(remoteDataSource.watchPolicies());

  @override
  Future<Either<Failure, WorkingHoursPolicyEntity>> createPolicy(WorkingHoursPolicyEntity policy) =>
      _guard(() => remoteDataSource.createPolicy(WorkingHoursPolicyModel(
            id: '',
            name: policy.name,
            startTime: policy.startTime,
            endTime: policy.endTime,
            standardHoursPerDay: policy.standardHoursPerDay,
          )));

  @override
  Stream<Either<Failure, List<WorkingHoursAssignmentEntity>>> watchAssignmentsForPolicy(
          String policyId) =>
      _guardStream(remoteDataSource.watchAssignmentsForPolicy(policyId));

  @override
  Future<Either<Failure, void>> assignPolicyToEmployees({
    required WorkingHoursPolicyEntity policy,
    required Map<String, String> employees,
    required DateTime start,
    required DateTime end,
  }) =>
      _guard(() => remoteDataSource.assignPolicyToEmployees(
            policy: WorkingHoursPolicyModel(
              id: policy.id,
              name: policy.name,
              startTime: policy.startTime,
              endTime: policy.endTime,
              standardHoursPerDay: policy.standardHoursPerDay,
            ),
            employees: employees,
            start: start,
            end: end,
          ));

  @override
  Future<Either<Failure, WorkingHoursPolicyEntity?>> getEffectivePolicyForEmployee(
      String employeeId) async {
    return _guard(() async {
      final assignments = await remoteDataSource.getAssignmentsForEmployee(employeeId);
      WorkingHoursAssignmentEntity? active;
      for (final a in assignments) {
        if (a.isActiveToday) {
          active = a;
          break;
        }
      }
      if (active == null) return null;

      return remoteDataSource.getPolicyById(active.policyId);
    });
  }
}
