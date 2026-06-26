import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/employee_repository.dart';

/// Super Admin only.
class DeleteEmployeeUseCase implements UseCase<void, String> {
  final EmployeeRepository repository;
  DeleteEmployeeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteEmployee(id);
  }
}
