import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_policy_entity.dart';
import '../repositories/working_hours_repository.dart';

/// Super Admin only.
class CreatePolicyUseCase implements UseCase<WorkingHoursPolicyEntity, WorkingHoursPolicyEntity> {
  final WorkingHoursRepository repository;
  CreatePolicyUseCase(this.repository);

  @override
  Future<Either<Failure, WorkingHoursPolicyEntity>> call(WorkingHoursPolicyEntity params) =>
      repository.createPolicy(params);
}
