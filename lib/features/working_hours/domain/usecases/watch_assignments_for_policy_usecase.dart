import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/stream_usecase.dart';
import '../entities/working_hours_assignment_entity.dart';
import '../repositories/working_hours_repository.dart';

class WatchAssignmentsForPolicyUseCase
    implements StreamUseCase<List<WorkingHoursAssignmentEntity>, String> {
  final WorkingHoursRepository repository;
  WatchAssignmentsForPolicyUseCase(this.repository);

  @override
  Stream<Either<Failure, List<WorkingHoursAssignmentEntity>>> call(String policyId) =>
      repository.watchAssignmentsForPolicy(policyId);
}
