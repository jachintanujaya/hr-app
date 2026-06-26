import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_policy_entity.dart';
import '../repositories/time_off_repository.dart';

/// Super Admin only.
class GetPoliciesUseCase implements UseCase<List<TimeOffPolicyEntity>, NoParams> {
  final TimeOffRepository repository;
  GetPoliciesUseCase(this.repository);

  @override
  Future<Either<Failure, List<TimeOffPolicyEntity>>> call(NoParams params) {
    return repository.getPolicies();
  }
}
