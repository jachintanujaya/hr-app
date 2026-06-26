import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EmployeeRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(PermissionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getTeamMembers() =>
      _guard(() => remoteDataSource.getTeamMembers());

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getAllEmployees({String? searchQuery}) =>
      _guard(() => remoteDataSource.getAllEmployees(searchQuery: searchQuery));

  @override
  Future<Either<Failure, EmployeeEntity>> getEmployeeById(String id) =>
      _guard(() => remoteDataSource.getEmployeeById(id));

  @override
  Future<Either<Failure, EmployeeEntity>> createEmployee(EmployeeEntity employee) =>
      _guard(() => remoteDataSource.createEmployee(EmployeeModel.fromEntity(employee)));

  @override
  Future<Either<Failure, EmployeeEntity>> updateEmployee(EmployeeEntity employee) =>
      _guard(() => remoteDataSource.updateEmployee(EmployeeModel.fromEntity(employee)));

  @override
  Future<Either<Failure, void>> deleteEmployee(String id) =>
      _guard(() => remoteDataSource.deleteEmployee(id));

  @override
  Future<Either<Failure, EmployeeEntity>> reassignRoleOrManager({
    required String employeeId,
    String? newRole,
    String? newManagerId,
  }) =>
      _guard(() => remoteDataSource.reassignRoleOrManager(
            employeeId: employeeId,
            newRole: newRole,
            newManagerId: newManagerId,
          ));
}
