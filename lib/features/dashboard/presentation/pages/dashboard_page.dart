import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/menu_grid_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>()
      ..add(const MyAttendanceRequested())
      ..add(const WorkingHoursSettingsRequested());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final permissions = state.permissions;

    if (user == null || permissions == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasAdminMenu = permissions.canViewTeamAttendance ||
        permissions.canApproveTeamTimeOff ||
        permissions.canManageTeamMembers ||
        permissions.canCreateOrDeleteEmployees ||
        permissions.canViewCompanyWideAttendanceReports ||
        permissions.canManageTimeOffPolicies ||
        permissions.canManageWorkingHoursSettings;

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

          const _AttendanceCard(),
          const SizedBox(height: 24),

          Text('Main Menu', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              MenuGridItem(
                icon: Icons.history,
                label: 'Attendance\nHistory',
                color: Colors.blue,
                onTap: () => context.push(AppRoutes.attendance),
              ),
              MenuGridItem(
                icon: Icons.beach_access,
                label: 'Time Off',
                color: Colors.orange,
                onTap: () => context.push(AppRoutes.timeOff),
              ),
              MenuGridItem(
                icon: Icons.person,
                label: 'My Profile',
                color: Colors.purple,
                onTap: () {},
              ),
            ],
          ),

          if (hasAdminMenu) ...[
            const SizedBox(height: 24),
            Text('Admin Menu', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                if (permissions.canViewTeamAttendance)
                  MenuGridItem(
                    icon: Icons.groups,
                    label: 'Team\nAttendance',
                    color: Colors.green,
                    onTap: () => context.push(AppRoutes.teamAttendance),
                  ),
                if (permissions.canApproveTeamTimeOff)
                  MenuGridItem(
                    icon: Icons.fact_check,
                    label: 'Approve\nTime Off',
                    color: Colors.amber,
                    onTap: () => context.push(AppRoutes.timeOffApprovals),
                  ),
                if (permissions.canManageTeamMembers)
                  MenuGridItem(
                    icon: Icons.manage_accounts,
                    label: 'Manage\nMy Team',
                    color: Colors.cyan,
                    onTap: () => context.push(AppRoutes.teamMembers),
                  ),
                if (permissions.canCreateOrDeleteEmployees)
                  MenuGridItem(
                    icon: Icons.badge,
                    label: 'All\nEmployees',
                    color: Colors.pink,
                    onTap: () => context.push(AppRoutes.allEmployees),
                  ),
                if (permissions.canViewCompanyWideAttendanceReports)
                  MenuGridItem(
                    icon: Icons.bar_chart,
                    label: 'Company\nReports',
                    color: Colors.brown,
                    onTap: () {},
                  ),
                if (permissions.canManageTimeOffPolicies || permissions.canManageWorkingHoursSettings)
                  MenuGridItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.blueGrey,
                    onTap: () => context.push(AppRoutes.settings),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceStatusFlag.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AttendanceStatusFlag.loading ||
            state.status == AttendanceStatusFlag.initial;
        final isActing = state.status == AttendanceStatusFlag.actionInProgress;

        final today = state.todayRecord;
        final clockInTime = today?.clockInTime;
        final clockOutTime = today?.clockOutTime;
        final isClockedIn = state.isClockedInNow;

        Duration worked = Duration.zero;
        if (clockInTime != null) {
          final end = clockOutTime ?? DateTime.now();
          worked = end.difference(clockInTime);
        }

        final canClockIn = !isLoading && !isActing && clockInTime == null;
        final canClockOut = !isLoading && !isActing && isClockedIn;
        final settings = state.workingHoursSettings;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Working Hours', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    _formatDuration(worked),
                    style:
                        Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 4),
                Text(
                  clockInTime == null
                      ? 'Not clocked in yet'
                      : clockOutTime == null
                          ? 'Since ${TimeOfDay.fromDateTime(clockInTime).format(context)}'
                          : 'Completed for today',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (settings != null) ...[
                  const SizedBox(height: 12),
                  Text('Target: ${settings.standardHoursPerDay.toStringAsFixed(1)}h/day',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (worked.inMinutes / (settings.standardHoursPerDay * 60))
                          .clamp(0, 1)
                          .toDouble(),
                      minHeight: 6,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.login),
                        label: Text(isActing && clockInTime == null ? 'Please wait...' : 'Clock In'),
                        onPressed: canClockIn
                            ? () => context.read<AttendanceBloc>().add(const ClockInRequested())
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.logout),
                        label: Text(isActing && isClockedIn ? 'Please wait...' : 'Clock Out'),
                        onPressed: canClockOut
                            ? () => context.read<AttendanceBloc>().add(const ClockOutRequested())
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: canClockOut ? Colors.redAccent : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
