import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/presentation/widgets/menu_grid_item.dart';

/// Hub for admin-level configuration screens. Only reachable if the user
/// has at least one settings-level permission (route is also guarded in
/// app_router.dart).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
        children: [
          if (permissions?.canManageTimeOffPolicies ?? false)
            MenuGridItem(
              icon: Icons.rule,
              label: 'Time Off Policies',
              color: Colors.deepPurple,
              onTap: () => context.push(AppRoutes.timeOffPolicies),
            ),
          if (permissions?.canManageWorkingHoursSettings ?? false)
            MenuGridItem(
              icon: Icons.punch_clock,
              label: 'Default Working Hours',
              color: Colors.teal,
              onTap: () => context.push(AppRoutes.workingHoursSettings),
            ),
          if (permissions?.canManageWorkingHoursSettings ?? false)
            MenuGridItem(
              icon: Icons.schedule,
              label: 'Working Hours Policies',
              color: Colors.indigo,
              onTap: () => context.push(AppRoutes.workingHoursPolicies),
            ),
        ],
      ),
    );
  }
}
