import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/permissions/user_role.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_bloc.dart';

/// Super Admin only — route is gated in app_router.dart.
class CreateEmployeePage extends StatefulWidget {
  const CreateEmployeePage({super.key});

  @override
  State<CreateEmployeePage> createState() => _CreateEmployeePageState();
}

class _CreateEmployeePageState extends State<CreateEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  UserRole _selectedRole = UserRole.employee;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EmployeeBloc>().add(EmployeeCreateRequested(
          EmployeeEntity(
            id: '', // backend assigns the real id
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            role: _selectedRole,
            jobTitle: _jobTitleController.text.trim().isEmpty ? null : _jobTitleController.text.trim(),
            department:
                _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Employee')),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state.status == EmployeeStatusFlag.actionSuccess) {
            Navigator.of(context).pop();
          }
          if (state.status == EmployeeStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == EmployeeStatusFlag.actionInProgress;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: 'Job title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedRole = value ?? UserRole.employee),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create Employee'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
