import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/time_off_balance_entity.dart';
import '../entities/time_off_policy_entity.dart';
import '../entities/time_off_request_entity.dart';

abstract class TimeOffRepository {
  Future<Either<Failure, TimeOffRequestEntity>> requestTimeOff(TimeOffRequestEntity request);

  /// Owner-only cancel of their own pending request.
  Future<Either<Failure, void>> cancelTimeOff(String requestId);

  /// Admin/Super Admin only.
  Future<Either<Failure, TimeOffRequestEntity>> approveTimeOff({
    required String requestId,
    String? note,
  });

  /// Admin/Super Admin only.
  Future<Either<Failure, TimeOffRequestEntity>> rejectTimeOff({
    required String requestId,
    String? note,
  });

  Future<Either<Failure, List<TimeOffRequestEntity>>> getMyRequests();

  /// Admin/Super Admin only: pending + historical requests from the team.
  Future<Either<Failure, List<TimeOffRequestEntity>>> getTeamRequests();

  Future<Either<Failure, List<TimeOffBalanceEntity>>> getMyBalances();

  /// Super Admin only.
  Future<Either<Failure, List<TimeOffPolicyEntity>>> getPolicies();

  /// Super Admin only.
  Future<Either<Failure, TimeOffPolicyEntity>> updatePolicy(TimeOffPolicyEntity policy);
}
