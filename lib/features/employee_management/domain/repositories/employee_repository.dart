import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  /// Admin/Super Admin: employees reporting directly to the current admin.
  Future<Either<Failure, List<EmployeeEntity>>> getTeamMembers();

  /// Super Admin only: every employee in the organization.
  Future<Either<Failure, List<EmployeeEntity>>> getAllEmployees({String? searchQuery});

  Future<Either<Failure, EmployeeEntity>> getEmployeeById(String id);

  /// Super Admin only.
  Future<Either<Failure, EmployeeEntity>> createEmployee(EmployeeEntity employee);

  /// Admin (limited fields) / Super Admin (all fields) — enforced server-side.
  Future<Either<Failure, EmployeeEntity>> updateEmployee(EmployeeEntity employee);

  /// Super Admin only.
  Future<Either<Failure, void>> deleteEmployee(String id);

  /// Super Admin only: change someone's role or reporting manager.
  Future<Either<Failure, EmployeeEntity>> reassignRoleOrManager({
    required String employeeId,
    String? newRole,
    String? newManagerId,
  });
}
