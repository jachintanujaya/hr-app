import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

/// Super Admin only — changes someone's role (e.g. promote employee to admin)
/// or who they report to.
class ReassignRoleOrManagerUseCase implements UseCase<EmployeeEntity, ReassignParams> {
  final EmployeeRepository repository;
  ReassignRoleOrManagerUseCase(this.repository);

  @override
  Future<Either<Failure, EmployeeEntity>> call(ReassignParams params) {
    return repository.reassignRoleOrManager(
      employeeId: params.employeeId,
      newRole: params.newRole,
      newManagerId: params.newManagerId,
    );
  }
}

class ReassignParams extends Equatable {
  final String employeeId;
  final String? newRole;
  final String? newManagerId;

  const ReassignParams({required this.employeeId, this.newRole, this.newManagerId});

  @override
  List<Object?> get props => [employeeId, newRole, newManagerId];
}
