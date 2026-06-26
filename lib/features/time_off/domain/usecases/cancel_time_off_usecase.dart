import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/time_off_repository.dart';

class CancelTimeOffUseCase implements UseCase<void, String> {
  final TimeOffRepository repository;
  CancelTimeOffUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String requestId) {
    return repository.cancelTimeOff(requestId);
  }
}
