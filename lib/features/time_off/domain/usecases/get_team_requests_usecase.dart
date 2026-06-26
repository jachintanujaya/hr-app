import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_request_entity.dart';
import '../repositories/time_off_repository.dart';

/// Admin/Super Admin only.
class GetTeamRequestsUseCase implements UseCase<List<TimeOffRequestEntity>, NoParams> {
  final TimeOffRepository repository;
  GetTeamRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TimeOffRequestEntity>>> call(NoParams params) {
    return repository.getTeamRequests();
  }
}
