import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_policy_entity.dart';
import '../repositories/working_hours_repository.dart';

/// Super Admin only.
class AssignPolicyUseCase implements UseCase<void, AssignPolicyParams> {
  final WorkingHoursRepository repository;
  AssignPolicyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AssignPolicyParams params) => repository.assignPolicyToEmployees(
        policy: params.policy,
        employees: params.employees,
        start: params.start,
        end: params.end,
      );
}

class AssignPolicyParams extends Equatable {
  final WorkingHoursPolicyEntity policy;
  final Map<String, String> employees;
  final DateTime start;
  final DateTime end;

  const AssignPolicyParams({
    required this.policy,
    required this.employees,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [policy, employees, start, end];
}
