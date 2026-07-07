import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/stream_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/working_hours_policy_entity.dart';
import '../repositories/working_hours_repository.dart';

class WatchPoliciesUseCase implements StreamUseCase<List<WorkingHoursPolicyEntity>, NoParams> {
  final WorkingHoursRepository repository;
  WatchPoliciesUseCase(this.repository);

  @override
  Stream<Either<Failure, List<WorkingHoursPolicyEntity>>> call(NoParams params) =>
      repository.watchPolicies();
}
