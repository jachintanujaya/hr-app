import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/clock_in_usecase.dart';
import '../../features/attendance/domain/usecases/clock_out_usecase.dart';
import '../../features/attendance/domain/usecases/get_my_attendance_usecase.dart';
import '../../features/attendance/domain/usecases/get_team_attendance_usecase.dart';
import '../../features/attendance/domain/usecases/update_attendance_record_usecase.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';

import '../../features/time_off/data/datasources/time_off_remote_datasource.dart';
import '../../features/time_off/data/repositories/time_off_repository_impl.dart';
import '../../features/time_off/domain/repositories/time_off_repository.dart';
import '../../features/time_off/domain/usecases/approve_time_off_usecase.dart';
import '../../features/time_off/domain/usecases/cancel_time_off_usecase.dart';
import '../../features/time_off/domain/usecases/get_my_balances_usecase.dart';
import '../../features/time_off/domain/usecases/get_my_requests_usecase.dart';
import '../../features/time_off/domain/usecases/get_policies_usecase.dart';
import '../../features/time_off/domain/usecases/get_team_requests_usecase.dart';
import '../../features/time_off/domain/usecases/reject_time_off_usecase.dart';
import '../../features/time_off/domain/usecases/request_time_off_usecase.dart';
import '../../features/time_off/domain/usecases/update_policy_usecase.dart';
import '../../features/time_off/presentation/bloc/time_off_bloc.dart';

import '../../features/employee_management/data/datasources/employee_remote_datasource.dart';
import '../../features/employee_management/data/repositories/employee_repository_impl.dart';
import '../../features/employee_management/domain/repositories/employee_repository.dart';
import '../../features/employee_management/domain/usecases/create_employee_usecase.dart';
import '../../features/employee_management/domain/usecases/delete_employee_usecase.dart';
import '../../features/employee_management/domain/usecases/get_all_employees_usecase.dart';
import '../../features/employee_management/domain/usecases/get_employee_by_id_usecase.dart';
import '../../features/employee_management/domain/usecases/get_team_members_usecase.dart';
import '../../features/employee_management/domain/usecases/reassign_role_or_manager_usecase.dart';
import '../../features/employee_management/domain/usecases/update_employee_usecase.dart';
import '../../features/employee_management/presentation/bloc/employee_bloc.dart';

/// Manual service-locator setup with get_it.
/// (You can switch to @injectable codegen later; this manual version
/// is explicit and easy to read while the app is young.)
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------------- Core ----------------
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient.create(sl()));

  // ---------------- Feature: Auth ----------------
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Bloc - registered as factory so a fresh instance is created if ever needed,
  // but in main.dart we provide ONE instance app-wide via BlocProvider.
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // ---------------- Feature: Attendance ----------------
  // TODO: register AttendanceRemoteDataSource, AttendanceRepository,
  // ClockInUseCase, ClockOutUseCase, GetTeamAttendanceUseCase, AttendanceBloc
  // following the exact same pattern as Auth above.

  // ---------------- Feature: Attendance ----------------
  sl.registerLazySingleton<AttendanceRemoteDataSource>(() => AttendanceRemoteDataSourceImpl(sl()));

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => ClockInUseCase(sl()));
  sl.registerLazySingleton(() => ClockOutUseCase(sl()));
  sl.registerLazySingleton(() => GetMyAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAttendanceRecordUseCase(sl()));

  sl.registerFactory(
    () => AttendanceBloc(
      clockInUseCase: sl(),
      clockOutUseCase: sl(),
      getMyAttendanceUseCase: sl(),
      getTeamAttendanceUseCase: sl(),
      updateAttendanceRecordUseCase: sl(),
    ),
  );

  // ---------------- Feature: Time off ----------------
  sl.registerLazySingleton<TimeOffRemoteDataSource>(() => TimeOffRemoteDataSourceImpl(sl()));

  sl.registerLazySingleton<TimeOffRepository>(
    () => TimeOffRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => RequestTimeOffUseCase(sl()));
  sl.registerLazySingleton(() => CancelTimeOffUseCase(sl()));
  sl.registerLazySingleton(() => ApproveTimeOffUseCase(sl()));
  sl.registerLazySingleton(() => RejectTimeOffUseCase(sl()));
  sl.registerLazySingleton(() => GetMyRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBalancesUseCase(sl()));
  sl.registerLazySingleton(() => GetPoliciesUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePolicyUseCase(sl()));

  sl.registerFactory(
    () => TimeOffBloc(
      requestTimeOffUseCase: sl(),
      cancelTimeOffUseCase: sl(),
      approveTimeOffUseCase: sl(),
      rejectTimeOffUseCase: sl(),
      getMyRequestsUseCase: sl(),
      getTeamRequestsUseCase: sl(),
      getMyBalancesUseCase: sl(),
      getPoliciesUseCase: sl(),
      updatePolicyUseCase: sl(),
    ),
  );

  // ---------------- Feature: Employee management ----------------
  sl.registerLazySingleton<EmployeeRemoteDataSource>(() => EmployeeRemoteDataSourceImpl(sl()));

  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetTeamMembersUseCase(sl()));
  sl.registerLazySingleton(() => GetAllEmployeesUseCase(sl()));
  sl.registerLazySingleton(() => GetEmployeeByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => ReassignRoleOrManagerUseCase(sl()));

  sl.registerFactory(
    () => EmployeeBloc(
      getTeamMembersUseCase: sl(),
      getAllEmployeesUseCase: sl(),
      getEmployeeByIdUseCase: sl(),
      createEmployeeUseCase: sl(),
      updateEmployeeUseCase: sl(),
      deleteEmployeeUseCase: sl(),
      reassignRoleOrManagerUseCase: sl(),
    ),
  );
}
