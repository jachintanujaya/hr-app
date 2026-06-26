import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/attendance_bloc.dart';

/// Every role sees this screen for their own attendance.
class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const MyAttendanceRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state.status == AttendanceStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AttendanceStatusFlag.loading;
          final isActing = state.status == AttendanceStatusFlag.actionInProgress;
          final today = state.todayRecord;

          return RefreshIndicator(
            onRefresh: () async => context.read<AttendanceBloc>().add(const MyAttendanceRequested()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        if (isLoading)
                          const CircularProgressIndicator()
                        else ...[
                          _TimeRow(label: 'Clock In', time: today?.clockInTime),
                          const SizedBox(height: 8),
                          _TimeRow(label: 'Clock Out', time: today?.clockOutTime),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            icon: Icon(state.isClockedInNow ? Icons.logout : Icons.login),
                            label: Text(isActing
                                ? 'Please wait...'
                                : state.isClockedInNow
                                    ? 'Clock Out'
                                    : 'Clock In'),
                            onPressed: isActing
                                ? null
                                : () {
                                    if (state.isClockedInNow) {
                                      context.read<AttendanceBloc>().add(const ClockOutRequested());
                                    } else {
                                      context.read<AttendanceBloc>().add(const ClockInRequested());
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: state.isClockedInNow ? Colors.redAccent : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Last 30 days', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...state.myAttendance.map((record) => Card(
                      child: ListTile(
                        title: Text(DateFormat('MMM d, yyyy').format(record.date)),
                        subtitle: Text(
                          record.isComplete
                              ? '${DateFormat.Hm().format(record.clockInTime!)} - ${DateFormat.Hm().format(record.clockOutTime!)}'
                              : record.clockInTime != null
                                  ? 'Clocked in at ${DateFormat.Hm().format(record.clockInTime!)}'
                                  : 'No record',
                        ),
                        trailing: Chip(label: Text(record.status.name)),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final DateTime? time;
  const _TimeRow({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          time != null ? DateFormat.Hm().format(time!) : '--:--',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
