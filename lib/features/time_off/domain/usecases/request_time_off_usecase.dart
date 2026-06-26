import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_request_entity.dart';
import '../repositories/time_off_repository.dart';

class RequestTimeOffUseCase implements UseCase<TimeOffRequestEntity, TimeOffRequestEntity> {
  final TimeOffRepository repository;
  RequestTimeOffUseCase(this.repository);

  @override
  Future<Either<Failure, TimeOffRequestEntity>> call(TimeOffRequestEntity params) {
    return repository.requestTimeOff(params);
  }
}
