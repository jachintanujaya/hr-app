import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> clockIn({String? note});
  Future<AttendanceModel> clockOut({String? note});
  Future<List<AttendanceModel>> getMyAttendance({required DateTime from, required DateTime to});
  Future<List<AttendanceModel>> getTeamAttendance({required DateTime from, required DateTime to});
  Future<AttendanceModel> updateAttendanceRecord(AttendanceModel record);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;
  AttendanceRemoteDataSourceImpl(this.dio);

  @override
  Future<AttendanceModel> clockIn({String? note}) async {
    try {
      final response = await dio.post(ApiConstants.clockIn, data: {if (note != null) 'note': note});
      return AttendanceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Clock-in failed',
          statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AttendanceModel> clockOut({String? note}) async {
    try {
      final response = await dio.post(ApiConstants.clockOut, data: {if (note != null) 'note': note});
      return AttendanceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Clock-out failed',
          statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<AttendanceModel>> getMyAttendance({required DateTime from, required DateTime to}) async {
    try {
      final response = await dio.get(ApiConstants.attendance, queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });
      final list = response.data['data'] as List;
      return list.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Failed to load attendance',
          statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<List<AttendanceModel>> getTeamAttendance({required DateTime from, required DateTime to}) async {
    try {
      final response = await dio.get(ApiConstants.teamAttendance, queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });
      final list = response.data['data'] as List;
      return list.map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AuthException('You do not have permission to view team attendance');
      }
      throw ServerException(e.response?.data?['message'] ?? 'Failed to load team attendance',
          statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AttendanceModel> updateAttendanceRecord(AttendanceModel record) async {
    try {
      final response = await dio.put(
        '${ApiConstants.attendance}/${record.id}',
        data: record.toJson(),
      );
      return AttendanceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AuthException('You do not have permission to edit this record');
      }
      throw ServerException(e.response?.data?['message'] ?? 'Failed to update record',
          statusCode: e.response?.statusCode);
    }
  }
}
