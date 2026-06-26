import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/permissions/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_bloc.dart';

/// View + edit a single employee. Field-level editability is governed by
/// Permissions: an admin can edit limited fields for their own team,
/// only a super admin can change role/manager (org structure) or delete.
class EmployeeDetailPage extends StatefulWidget {
  final String employeeId;
  const EmployeeDetailPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _initializedFields = false;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(EmployeeDetailRequested(widget.employeeId));
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _populateFieldsIfNeeded(EmployeeEntity employee) {
    if (_initializedFields) return;
    _jobTitleController.text = employee.jobTitle ?? '';
    _departmentController.text = employee.department ?? '';
    _initializedFields = true;
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          if (permissions?.canCreateOrDeleteEmployees ?? false)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state.status == EmployeeStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == EmployeeStatusFlag.actionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
          }
        },
        builder: (context, state) {
          final employee = state.selectedEmployee;
          if (state.status == EmployeeStatusFlag.loading || employee == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _populateFieldsIfNeeded(employee);
          final canEdit = permissions?.canManageTeamMembers ?? false;
          final canManageOrgStructure = permissions?.canManageOrgStructure ?? false;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  child: Text(
                    employee.fullName.isNotEmpty ? employee.fullName[0] : '?',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(employee.fullName, style: Theme.of(context).textTheme.headlineSmall),
              ),
              Center(child: Text(employee.email, style: Theme.of(context).textTheme.bodyMedium)),
              const SizedBox(height: 24),

              TextField(
                controller: _jobTitleController,
                enabled: canEdit,
                decoration: const InputDecoration(labelText: 'Job title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _departmentController,
                enabled: canEdit,
                decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              // Role & manager — org structure changes, Super Admin only.
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Role'),
                subtitle: Text(employee.role.label),
                trailing: canManageOrgStructure
                    ? DropdownButton<UserRole>(
                        value: employee.role,
                        items: UserRole.values
                            .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                            .toList(),
                        onChanged: (newRole) {
                          if (newRole == null) return;
                          context.read<EmployeeBloc>().add(EmployeeReassignRequested(
                                employeeId: employee.id,
                                newRole: newRole.name,
                              ));
                        },
                      )
                    : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reports to'),
                subtitle: Text(employee.managerName ?? 'Unassigned'),
                trailing: canManageOrgStructure
                    ? const Icon(Icons.edit, size: 18)
                    : null,
                onTap: canManageOrgStructure
                    ? () {
                        // TODO: open a manager-picker (search team admins) and dispatch
                        // EmployeeReassignRequested(employeeId: employee.id, newManagerId: pickedId)
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Status'),
                trailing: Chip(label: Text(employee.status.name)),
              ),

              if (canEdit) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.status == EmployeeStatusFlag.actionInProgress
                      ? null
                      : () {
                          context.read<EmployeeBloc>().add(EmployeeUpdateRequested(
                                employee.copyWith(
                                  jobTitle: _jobTitleController.text,
                                  department: _departmentController.text,
                                ),
                              ));
                        },
                  child: const Text('Save Changes'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete employee?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<EmployeeBloc>().add(EmployeeDeleteRequested(widget.employeeId));
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
