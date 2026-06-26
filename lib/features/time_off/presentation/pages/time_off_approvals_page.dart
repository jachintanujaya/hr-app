import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/time_off_request_entity.dart';
import '../bloc/time_off_bloc.dart';

/// Admin & Super Admin only — approve/reject the team's pending requests.
class TimeOffApprovalsPage extends StatefulWidget {
  const TimeOffApprovalsPage({super.key});

  @override
  State<TimeOffApprovalsPage> createState() => _TimeOffApprovalsPageState();
}

class _TimeOffApprovalsPageState extends State<TimeOffApprovalsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TimeOffBloc>().add(const TeamTimeOffRequested());
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    if (permissions == null || !permissions.canApproveTeamTimeOff) {
      return const Scaffold(body: Center(child: Text("You don't have access to this page")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Time Off Approvals')),
      body: BlocConsumer<TimeOffBloc, TimeOffState>(
        listener: (context, state) {
          if (state.status == TimeOffStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == TimeOffStatusFlag.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final pending = state.pendingTeamRequests;
          if (pending.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<TimeOffBloc>().add(const TeamTimeOffRequested()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _ApprovalCard(request: pending[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final TimeOffRequestEntity request;
  const _ApprovalCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.employeeName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${request.type.name} — ${request.totalDays} day(s)'),
            Text('${dateFmt.format(request.startDate)} - ${dateFmt.format(request.endDate)}'),
            if (request.reason != null) ...[
              const SizedBox(height: 4),
              Text(request.reason!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    onPressed: () => context.read<TimeOffBloc>().add(TimeOffRejectRequested(request.id)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    onPressed: () =>
                        context.read<TimeOffBloc>().add(TimeOffApproveRequested(request.id)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
