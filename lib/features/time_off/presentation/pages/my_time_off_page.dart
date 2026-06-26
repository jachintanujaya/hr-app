import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/time_off_request_entity.dart';
import '../bloc/time_off_bloc.dart';
import 'request_time_off_page.dart';

/// Everyone's screen: balances, request history, request/cancel actions.
class MyTimeOffPage extends StatefulWidget {
  const MyTimeOffPage({super.key});

  @override
  State<MyTimeOffPage> createState() => _MyTimeOffPageState();
}

class _MyTimeOffPageState extends State<MyTimeOffPage> {
  @override
  void initState() {
    super.initState();
    context.read<TimeOffBloc>().add(const MyTimeOffRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Off')),
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
          return RefreshIndicator(
            onRefresh: () async => context.read<TimeOffBloc>().add(const MyTimeOffRequested()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.myBalances.isNotEmpty) ...[
                  Text('Balances', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.myBalances
                        .map((b) => Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.type.name, style: Theme.of(context).textTheme.bodySmall),
                                    Text('${b.remainingDays.toStringAsFixed(0)} days left',
                                        style: Theme.of(context).textTheme.titleMedium),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                Text('My Requests', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (state.myRequests.isEmpty) const Text('No requests yet'),
                ...state.myRequests.map((r) => _RequestTile(request: r)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Request Time Off'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TimeOffBloc>(),
              child: const RequestTimeOffPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final TimeOffRequestEntity request;
  const _RequestTile({required this.request});

  Color _statusColor() {
    switch (request.status) {
      case TimeOffStatus.approved:
        return Colors.green;
      case TimeOffStatus.rejected:
        return Colors.red;
      case TimeOffStatus.cancelled:
        return Colors.grey;
      case TimeOffStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d');
    return Card(
      child: ListTile(
        title: Text('${request.type.name} — ${request.totalDays} day(s)'),
        subtitle: Text(
          '${dateFmt.format(request.startDate)} - ${dateFmt.format(request.endDate)}'
          '${request.reason != null ? '\n${request.reason}' : ''}',
        ),
        isThreeLine: request.reason != null,
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text(request.status.name),
              backgroundColor: _statusColor().withOpacity(0.15),
              labelStyle: TextStyle(color: _statusColor()),
            ),
            if (request.canBeCancelledByOwner)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Cancel request',
                onPressed: () => context.read<TimeOffBloc>().add(TimeOffCancelRequested(request.id)),
              ),
          ],
        ),
      ),
    );
  }
}
