import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/time_off_policy_entity.dart';
import '../bloc/time_off_bloc.dart';

/// Super Admin (HR) only — configures org-wide time off rules per type.
class TimeOffPoliciesPage extends StatefulWidget {
  const TimeOffPoliciesPage({super.key});

  @override
  State<TimeOffPoliciesPage> createState() => _TimeOffPoliciesPageState();
}

class _TimeOffPoliciesPageState extends State<TimeOffPoliciesPage> {
  @override
  void initState() {
    super.initState();
    context.read<TimeOffBloc>().add(const PoliciesRequested());
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    if (permissions == null || !permissions.canManageTimeOffPolicies) {
      return const Scaffold(body: Center(child: Text("You don't have access to this page")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Time Off Policies')),
      body: BlocConsumer<TimeOffBloc, TimeOffState>(
        listener: (context, state) {
          if (state.status == TimeOffStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == TimeOffStatusFlag.actionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Policy updated')));
          }
        },
        builder: (context, state) {
          if (state.status == TimeOffStatusFlag.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.policies.isEmpty) {
            return const Center(child: Text('No policies configured'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.policies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _PolicyCard(policy: state.policies[index]),
          );
        },
      ),
    );
  }
}

class _PolicyCard extends StatefulWidget {
  final TimeOffPolicyEntity policy;
  const _PolicyCard({required this.policy});

  @override
  State<_PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<_PolicyCard> {
  late TextEditingController _allowanceController;

  @override
  void initState() {
    super.initState();
    _allowanceController =
        TextEditingController(text: widget.policy.annualAllowanceDays.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _allowanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policy = widget.policy;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(policy.type.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _allowanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Annual allowance (days)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Requires approval'),
              value: policy.requiresApproval,
              onChanged: (value) {
                context.read<TimeOffBloc>().add(
                      PolicyUpdateRequested(policy.copyWith(requiresApproval: value)),
                    );
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Carries over to next year'),
              value: policy.carriesOverToNextYear,
              onChanged: (value) {
                context.read<TimeOffBloc>().add(
                      PolicyUpdateRequested(policy.copyWith(carriesOverToNextYear: value)),
                    );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  final parsed = double.tryParse(_allowanceController.text);
                  if (parsed == null) return;
                  context.read<TimeOffBloc>().add(
                        PolicyUpdateRequested(policy.copyWith(annualAllowanceDays: parsed)),
                      );
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
