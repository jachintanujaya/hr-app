import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetTeamMembersUseCase implements UseCase<List<EmployeeEntity>, NoParams> {
  final EmployeeRepository repository;
  GetTeamMembersUseCase(this.repository);

  @override
  Future<Either<Failure, List<EmployeeEntity>>> call(NoParams params) {
    return repository.getTeamMembers();
  }
}
