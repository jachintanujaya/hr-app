import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getTeamMembers();
  Future<List<EmployeeModel>> getAllEmployees({String? searchQuery});
  Future<EmployeeModel> getEmployeeById(String id);
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String id);
  Future<EmployeeModel> reassignRoleOrManager({
    required String employeeId,
    String? newRole,
    String? newManagerId,
  });
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final Dio dio;
  EmployeeRemoteDataSourceImpl(this.dio);

  Never _throwFromDio(DioException e, String fallback) {
    if (e.response?.statusCode == 403) {
      throw AuthException('You do not have permission to perform this action');
    }
    if (e.response?.statusCode == 404) {
      throw ServerException('Employee not found', statusCode: 404);
    }
    throw ServerException(e.response?.data?['message'] ?? fallback,
        statusCode: e.response?.statusCode);
  }

  @override
  Future<List<EmployeeModel>> getTeamMembers() async {
    try {
      final response = await dio.get('${ApiConstants.employees}/team');
      final list = response.data['data'] as List;
      return list.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load team members');
    }
  }

  @override
  Future<List<EmployeeModel>> getAllEmployees({String? searchQuery}) async {
    try {
      final response = await dio.get(
        ApiConstants.employees,
        queryParameters: {if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery},
      );
      final list = response.data['data'] as List;
      return list.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load employees');
    }
  }

  @override
  Future<EmployeeModel> getEmployeeById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.employees}/$id');
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load employee');
    }
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      final response = await dio.post(ApiConstants.employees, data: employee.toJson());
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to create employee');
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(EmployeeModel employee) async {
    try {
      final response = await dio.put(
        '${ApiConstants.employees}/${employee.id}',
        data: employee.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to update employee');
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await dio.delete('${ApiConstants.employees}/$id');
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to delete employee');
    }
  }

  @override
  Future<EmployeeModel> reassignRoleOrManager({
    required String employeeId,
    String? newRole,
    String? newManagerId,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.employees}/$employeeId/reassign',
        data: {
          if (newRole != null) 'role': newRole,
          if (newManagerId != null) 'manager_id': newManagerId,
        },
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to reassign employee');
    }
  }
}
