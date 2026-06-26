import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetAllEmployeesUseCase implements UseCase<List<EmployeeEntity>, SearchParams> {
  final EmployeeRepository repository;
  GetAllEmployeesUseCase(this.repository);

  @override
  Future<Either<Failure, List<EmployeeEntity>>> call(SearchParams params) {
    return repository.getAllEmployees(searchQuery: params.query);
  }
}

class SearchParams extends Equatable {
  final String? query;
  const SearchParams({this.query});

  @override
  List<Object?> get props => [query];
}
