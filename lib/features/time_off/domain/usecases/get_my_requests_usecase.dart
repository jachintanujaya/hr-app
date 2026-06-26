import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_request_entity.dart';
import '../repositories/time_off_repository.dart';

class GetMyRequestsUseCase implements UseCase<List<TimeOffRequestEntity>, NoParams> {
  final TimeOffRepository repository;
  GetMyRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TimeOffRequestEntity>>> call(NoParams params) {
    return repository.getMyRequests();
  }
}
