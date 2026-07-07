import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/working_hours_policy_entity.dart';
import '../bloc/working_hours_bloc.dart';

/// Super Admin only — lists WFO/WFC/etc policies, lets you create new ones,
/// and taps through to assign a policy to employees.
class WorkingHoursPoliciesPage extends StatefulWidget {
  const WorkingHoursPoliciesPage({super.key});

  @override
  State<WorkingHoursPoliciesPage> createState() => _WorkingHoursPoliciesPageState();
}

class _WorkingHoursPoliciesPageState extends State<WorkingHoursPoliciesPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkingHoursBloc>().add(const PoliciesWatchStarted());
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final hoursController = TextEditingController(text: '8');
    TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 17, minute: 0);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Working Hours Policy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name (e.g. WFO, WFC)'),
                ),
                TextField(
                  controller: hoursController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Standard hours per day'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Start time'),
                  trailing: Text(start.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: start);
                    if (picked != null) setDialogState(() => start = picked);
                  },
                ),
                ListTile(
                  title: const Text('End time'),
                  trailing: Text(end.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: end);
                    if (picked != null) setDialogState(() => end = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final hours = double.tryParse(hoursController.text);
                if (name.isEmpty || hours == null || hours <= 0) return;
                String fmt(TimeOfDay t) =>
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                context.read<WorkingHoursBloc>().add(PolicyCreateRequested(
                      WorkingHoursPolicyEntity(
                        id: '',
                        name: name,
                        startTime: fmt(start),
                        endTime: fmt(end),
                        standardHoursPerDay: hours,
                      ),
                    ));
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Working Hours Policies')),
      body: BlocConsumer<WorkingHoursBloc, WorkingHoursState>(
        listener: (context, state) {
          if (state.status == WorkingHoursStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == WorkingHoursStatusFlag.loading && state.policies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.policies.isEmpty) {
            return const Center(child: Text('No policies yet — tap + to create one'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.policies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final policy = state.policies[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.schedule)),
                  title: Text(policy.name),
                  subtitle: Text(
                      '${policy.startTime} - ${policy.endTime}  •  ${policy.standardHoursPerDay}h/day'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    AppRoutes.workingHoursPolicyAssign.replaceFirst(':policyId', policy.id),
                    extra: policy,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
