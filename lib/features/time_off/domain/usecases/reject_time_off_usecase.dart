import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_request_entity.dart';
import '../repositories/time_off_repository.dart';
import 'approve_time_off_usecase.dart';

/// Admin/Super Admin only.
class RejectTimeOffUseCase implements UseCase<TimeOffRequestEntity, DecisionParams> {
  final TimeOffRepository repository;
  RejectTimeOffUseCase(this.repository);

  @override
  Future<Either<Failure, TimeOffRequestEntity>> call(DecisionParams params) {
    return repository.rejectTimeOff(requestId: params.requestId, note: params.note);
  }
}
