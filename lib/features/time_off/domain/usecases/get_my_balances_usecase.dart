import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_balance_entity.dart';
import '../repositories/time_off_repository.dart';

class GetMyBalancesUseCase implements UseCase<List<TimeOffBalanceEntity>, NoParams> {
  final TimeOffRepository repository;
  GetMyBalancesUseCase(this.repository);

  @override
  Future<Either<Failure, List<TimeOffBalanceEntity>>> call(NoParams params) {
    return repository.getMyBalances();
  }
}
