import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/attendance/presentation/pages/clock_in_out_page.dart';
import '../../features/attendance/presentation/pages/team_attendance_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/employee_management/presentation/bloc/employee_bloc.dart';
import '../../features/employee_management/presentation/pages/all_employees_page.dart';
import '../../features/employee_management/presentation/pages/create_employee_page.dart';
import '../../features/employee_management/presentation/pages/employee_detail_page.dart';
import '../../features/employee_management/presentation/pages/team_members_page.dart';
import '../../features/time_off/presentation/bloc/time_off_bloc.dart';
import '../../features/time_off/presentation/pages/my_time_off_page.dart';
import '../../features/time_off/presentation/pages/time_off_approvals_page.dart';
import '../../features/time_off/presentation/pages/time_off_policies_page.dart';
import '../di/injection_container.dart';
import 'app_routes.dart';

/// Centralized router with role-aware redirects.
/// `refreshListenable` re-runs `redirect` every time AuthBloc emits a new
/// state, so login/logout instantly reroutes the user without manual nav calls.
GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: _AuthBlocRefreshStream(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final loggingIn = state.matchedLocation == AppRoutes.login;

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isUnauthenticated = authState.status == AuthStatus.unauthenticated ||
          authState.status == AuthStatus.failure;

      if (isUnauthenticated && !loggingIn) return AppRoutes.login;
      if (isAuthenticated && loggingIn) return AppRoutes.dashboard;

      // Role-gated routes: bounce back to dashboard if the user lacks permission.
      // This is a UX nicety only — the backend must enforce this too.
      if (state.matchedLocation == AppRoutes.teamAttendance &&
          !(authState.permissions?.canViewTeamAttendance ?? false)) {
        return AppRoutes.dashboard;
      }
      if (state.matchedLocation == AppRoutes.timeOffApprovals &&
          !(authState.permissions?.canApproveTeamTimeOff ?? false)) {
        return AppRoutes.dashboard;
      }
      if (state.matchedLocation == AppRoutes.timeOffPolicies &&
          !(authState.permissions?.canManageTimeOffPolicies ?? false)) {
        return AppRoutes.dashboard;
      }
      if (state.matchedLocation == AppRoutes.teamMembers &&
          !(authState.permissions?.canManageTeamMembers ?? false)) {
        return AppRoutes.dashboard;
      }
      if (state.matchedLocation.startsWith(AppRoutes.allEmployees) &&
          !(authState.permissions?.canCreateOrDeleteEmployees ?? false)) {
        return AppRoutes.dashboard;
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AttendanceBloc>(),
          child: const ClockInOutPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.teamAttendance,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AttendanceBloc>(),
          child: const TeamAttendancePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.timeOff,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TimeOffBloc>(),
          child: const MyTimeOffPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.timeOffApprovals,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TimeOffBloc>(),
          child: const TimeOffApprovalsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.timeOffPolicies,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<TimeOffBloc>(),
          child: const TimeOffPoliciesPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.teamMembers,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<EmployeeBloc>(),
          child: const TeamMembersPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.allEmployees,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<EmployeeBloc>(),
          child: const AllEmployeesPage(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<EmployeeBloc>(),
              child: const CreateEmployeePage(),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<EmployeeBloc>(),
              child: EmployeeDetailPage(employeeId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Bridges Bloc's stream-based state changes to GoRouter's Listenable API.
class _AuthBlocRefreshStream extends ChangeNotifier {
  late final dynamic _subscription;

  _AuthBlocRefreshStream(AuthBloc authBloc) {
    notifyListeners();
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
