import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeByIdUseCase implements UseCase<EmployeeEntity, String> {
  final EmployeeRepository repository;
  GetEmployeeByIdUseCase(this.repository);

  @override
  Future<Either<Failure, EmployeeEntity>> call(String id) {
    return repository.getEmployeeById(id);
  }
}
