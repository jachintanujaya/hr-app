import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployeeUseCase implements UseCase<EmployeeEntity, EmployeeEntity> {
  final EmployeeRepository repository;
  UpdateEmployeeUseCase(this.repository);

  @override
  Future<Either<Failure, EmployeeEntity>> call(EmployeeEntity params) {
    return repository.updateEmployee(params);
  }
}
