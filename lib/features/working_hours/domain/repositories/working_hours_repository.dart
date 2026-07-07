import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/working_hours_assignment_entity.dart';
import '../entities/working_hours_policy_entity.dart';

abstract class WorkingHoursRepository {
  /// Live list of all policies (WFO, WFC, etc). Read by everyone; only
  /// Super Admin sees the create/assign controls in the UI.
  Stream<Either<Failure, List<WorkingHoursPolicyEntity>>> watchPolicies();

  Future<Either<Failure, WorkingHoursPolicyEntity>> createPolicy(WorkingHoursPolicyEntity policy);

  /// Live list of assignments for a given policy (used on the policy's
  /// "assigned employees" screen, split into active/upcoming vs history).
  Stream<Either<Failure, List<WorkingHoursAssignmentEntity>>> watchAssignmentsForPolicy(
      String policyId);

  /// Assigns [policy] to every employee in [employees] for [start]..[end].
  /// Validates no overlapping assignment exists per employee first; returns
  /// a [ValidationFailure] listing the conflicting employee(s) if so, and
  /// writes nothing in that case.
  Future<Either<Failure, void>> assignPolicyToEmployees({
    required WorkingHoursPolicyEntity policy,
    required Map<String, String> employees, // id -> name
    required DateTime start,
    required DateTime end,
  });

  /// The policy currently in effect for [employeeId] today, or null if no
  /// assignment covers today (caller should fall back to org default).
  Future<Either<Failure, WorkingHoursPolicyEntity?>> getEffectivePolicyForEmployee(
      String employeeId);
}
