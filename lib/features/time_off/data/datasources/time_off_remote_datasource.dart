import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/time_off_balance_model.dart';
import '../models/time_off_policy_model.dart';
import '../models/time_off_request_model.dart';

abstract class TimeOffRemoteDataSource {
  Future<TimeOffRequestModel> requestTimeOff(TimeOffRequestModel request);
  Future<void> cancelTimeOff(String requestId);
  Future<TimeOffRequestModel> approveTimeOff({required String requestId, String? note});
  Future<TimeOffRequestModel> rejectTimeOff({required String requestId, String? note});
  Future<List<TimeOffRequestModel>> getMyRequests();
  Future<List<TimeOffRequestModel>> getTeamRequests();
  Future<List<TimeOffBalanceModel>> getMyBalances();
  Future<List<TimeOffPolicyModel>> getPolicies();
  Future<TimeOffPolicyModel> updatePolicy(TimeOffPolicyModel policy);
}

class TimeOffRemoteDataSourceImpl implements TimeOffRemoteDataSource {
  final Dio dio;
  TimeOffRemoteDataSourceImpl(this.dio);

  Never _throwFromDio(DioException e, String fallback) {
    if (e.response?.statusCode == 403) {
      throw AuthException('You do not have permission to perform this action');
    }
    if (e.response?.statusCode == 404) {
      throw ServerException('Request not found', statusCode: 404);
    }
    throw ServerException(e.response?.data?['message'] ?? fallback,
        statusCode: e.response?.statusCode);
  }

  @override
  Future<TimeOffRequestModel> requestTimeOff(TimeOffRequestModel request) async {
    try {
      final response = await dio.post(ApiConstants.timeOffRequests, data: request.toJson());
      return TimeOffRequestModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to submit time off request');
    }
  }

  @override
  Future<void> cancelTimeOff(String requestId) async {
    try {
      await dio.post('${ApiConstants.timeOffRequests}/$requestId/cancel');
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to cancel request');
    }
  }

  @override
  Future<TimeOffRequestModel> approveTimeOff({required String requestId, String? note}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.timeOffRequests}/$requestId/approve',
        data: {if (note != null) 'note': note},
      );
      return TimeOffRequestModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to approve request');
    }
  }

  @override
  Future<TimeOffRequestModel> rejectTimeOff({required String requestId, String? note}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.timeOffRequests}/$requestId/reject',
        data: {if (note != null) 'note': note},
      );
      return TimeOffRequestModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to reject request');
    }
  }

  @override
  Future<List<TimeOffRequestModel>> getMyRequests() async {
    try {
      final response = await dio.get(ApiConstants.timeOffRequests);
      final list = response.data['data'] as List;
      return list.map((e) => TimeOffRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load your requests');
    }
  }

  @override
  Future<List<TimeOffRequestModel>> getTeamRequests() async {
    try {
      final response = await dio.get('${ApiConstants.timeOffRequests}/team');
      final list = response.data['data'] as List;
      return list.map((e) => TimeOffRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load team requests');
    }
  }

  @override
  Future<List<TimeOffBalanceModel>> getMyBalances() async {
    try {
      final response = await dio.get(ApiConstants.timeOffBalances);
      final list = response.data['data'] as List;
      return list.map((e) => TimeOffBalanceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load balances');
    }
  }

  @override
  Future<List<TimeOffPolicyModel>> getPolicies() async {
    try {
      final response = await dio.get(ApiConstants.timeOffPolicies);
      final list = response.data['data'] as List;
      return list.map((e) => TimeOffPolicyModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load policies');
    }
  }

  @override
  Future<TimeOffPolicyModel> updatePolicy(TimeOffPolicyModel policy) async {
    try {
      final response = await dio.put(
        '${ApiConstants.timeOffPolicies}/${policy.id}',
        data: policy.toJson(),
      );
      return TimeOffPolicyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to update policy');
    }
  }
}
