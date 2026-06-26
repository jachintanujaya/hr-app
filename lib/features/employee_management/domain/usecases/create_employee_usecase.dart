import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

/// Super Admin only — gate the UI entry point with Permissions.canCreateOrDeleteEmployees
/// before dispatching this; the backend must also enforce it.
class CreateEmployeeUseCase implements UseCase<EmployeeEntity, EmployeeEntity> {
  final EmployeeRepository repository;
  CreateEmployeeUseCase(this.repository);

  @override
  Future<Either<Failure, EmployeeEntity>> call(EmployeeEntity params) {
    return repository.createEmployee(params);
  }
}
