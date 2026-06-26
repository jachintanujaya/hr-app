import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_off_request_entity.dart';
import '../repositories/time_off_repository.dart';

/// Admin/Super Admin only — gate the UI with Permissions.canApproveTeamTimeOff.
class ApproveTimeOffUseCase implements UseCase<TimeOffRequestEntity, DecisionParams> {
  final TimeOffRepository repository;
  ApproveTimeOffUseCase(this.repository);

  @override
  Future<Either<Failure, TimeOffRequestEntity>> call(DecisionParams params) {
    return repository.approveTimeOff(requestId: params.requestId, note: params.note);
  }
}

class DecisionParams extends Equatable {
  final String requestId;
  final String? note;
  const DecisionParams({required this.requestId, this.note});

  @override
  List<Object?> get props => [requestId, note];
}
