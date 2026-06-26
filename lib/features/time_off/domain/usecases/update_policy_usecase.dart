import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_policy_entity.dart';
import '../repositories/time_off_repository.dart';

/// Super Admin only.
class UpdatePolicyUseCase implements UseCase<TimeOffPolicyEntity, TimeOffPolicyEntity> {
  final TimeOffRepository repository;
  UpdatePolicyUseCase(this.repository);

  @override
  Future<Either<Failure, TimeOffPolicyEntity>> call(TimeOffPolicyEntity params) {
    return repository.updatePolicy(params);
  }
}
