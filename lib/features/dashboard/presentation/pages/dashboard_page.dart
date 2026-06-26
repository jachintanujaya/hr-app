import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Shows the same screen for every role, but composes different sections
/// based on Permissions — this is the pattern to copy for every other
/// role-aware screen in the app.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final permissions = state.permissions;

    if (user == null || permissions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.fullName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Chip(label: Text(user.role.label)),
          const SizedBox(height: 16),

          // Everyone sees these
          _SectionTile(
            icon: Icons.access_time,
            title: 'Clock In / Out',
            onTap: () => context.push(AppRoutes.attendance),
          ),
          _SectionTile(
            icon: Icons.beach_access,
            title: 'Request Time Off',
            onTap: () => context.push(AppRoutes.timeOff),
          ),
          _SectionTile(icon: Icons.person, title: 'My Profile', onTap: () {}),

          // Admin + Super Admin only
          if (permissions.canViewTeamAttendance)
            _SectionTile(
              icon: Icons.groups,
              title: 'Team Attendance',
              onTap: () => context.push(AppRoutes.teamAttendance),
            ),
          if (permissions.canApproveTeamTimeOff)
            _SectionTile(
              icon: Icons.fact_check,
              title: 'Approve Time Off Requests',
              onTap: () => context.push(AppRoutes.timeOffApprovals),
            ),
          if (permissions.canManageTeamMembers)
            _SectionTile(
              icon: Icons.manage_accounts,
              title: 'Manage My Team',
              onTap: () => context.push(AppRoutes.teamMembers),
            ),

          // Super Admin only
          if (permissions.canCreateOrDeleteEmployees)
            _SectionTile(
              icon: Icons.badge,
              title: 'All Employees',
              onTap: () => context.push(AppRoutes.allEmployees),
            ),
          if (permissions.canManageTimeOffPolicies)
            _SectionTile(
              icon: Icons.rule,
              title: 'Time Off Policies',
              onTap: () => context.push(AppRoutes.timeOffPolicies),
            ),
          if (permissions.canViewCompanyWideAttendanceReports)
            _SectionTile(icon: Icons.bar_chart, title: 'Company Reports', onTap: () {}),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SectionTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
