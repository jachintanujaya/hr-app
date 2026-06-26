import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_bloc.dart';

/// Super Admin only — full org directory, with search and create access.
/// The route to this page is gated in app_router.dart via
/// Permissions.canCreateOrDeleteEmployees, but we double check here too.
class AllEmployeesPage extends StatefulWidget {
  const AllEmployeesPage({super.key});

  @override
  State<AllEmployeesPage> createState() => _AllEmployeesPageState();
}

class _AllEmployeesPageState extends State<AllEmployeesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const AllEmployeesRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    if (permissions == null || !permissions.canCreateOrDeleteEmployees) {
      return const Scaffold(body: Center(child: Text("You don't have access to this page")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All Employees')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (value) =>
                  context.read<EmployeeBloc>().add(AllEmployeesRequested(searchQuery: value)),
            ),
          ),
          Expanded(
            child: BlocConsumer<EmployeeBloc, EmployeeState>(
              listener: (context, state) {
                if (state.status == EmployeeStatusFlag.failure && state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                }
              },
              builder: (context, state) {
                if (state.status == EmployeeStatusFlag.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.allEmployees.isEmpty) {
                  return const Center(child: Text('No employees found'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.allEmployees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final employee = state.allEmployees[index];
                    return _EmployeeCard(employee: employee);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${AppRoutes.allEmployees}/new'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeEntity employee;
  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(employee.fullName.isNotEmpty ? employee.fullName[0] : '?')),
        title: Text(employee.fullName),
        subtitle: Text('${employee.jobTitle ?? '—'}  •  ${employee.department ?? '—'}'),
        trailing: Chip(label: Text(employee.role.label)),
        onTap: () => context.push('${AppRoutes.allEmployees}/${employee.id}'),
      ),
    );
  }
}
