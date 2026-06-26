import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_bloc.dart';

/// Admin & Super Admin — shows the people reporting to the current admin.
class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({super.key});

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const TeamMembersRequested());
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    return Scaffold(
      appBar: AppBar(title: const Text('My Team')),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state.status == EmployeeStatusFlag.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.teamMembers.isEmpty) {
            return const Center(child: Text('No team members yet'));
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<EmployeeBloc>().add(const TeamMembersRequested()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.teamMembers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _EmployeeTile(employee: state.teamMembers[index]),
            ),
          );
        },
      ),
      floatingActionButton: (permissions?.canCreateOrDeleteEmployees ?? false)
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.allEmployees),
              child: const Icon(Icons.groups),
            )
          : null,
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  final EmployeeEntity employee;
  const _EmployeeTile({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(employee.fullName.isNotEmpty ? employee.fullName[0] : '?')),
        title: Text(employee.fullName),
        subtitle: Text(employee.jobTitle ?? employee.email),
        trailing: Chip(label: Text(employee.role.label)),
        onTap: () => context.push('${AppRoutes.allEmployees}/${employee.id}'),
      ),
    );
  }
}
