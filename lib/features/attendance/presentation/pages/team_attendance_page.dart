import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../bloc/attendance_bloc.dart';

/// Admin & Super Admin only. The route to this page should already be
/// gated in app_router.dart via Permissions.canViewTeamAttendance, but we
/// double-check here too, since defense in depth costs nothing.
class TeamAttendancePage extends StatefulWidget {
  const TeamAttendancePage({super.key});

  @override
  State<TeamAttendancePage> createState() => _TeamAttendancePageState();
}

class _TeamAttendancePageState extends State<TeamAttendancePage> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<AttendanceBloc>().add(
          TeamAttendanceRequested(from: DateTime(now.year, now.month, now.day), to: now),
        );
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    if (permissions == null || !permissions.canViewTeamAttendance) {
      return const Scaffold(
        body: Center(child: Text("You don't have access to this page")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Team Attendance')),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state.status == AttendanceStatusFlag.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.teamAttendance.isEmpty) {
            return const Center(child: Text('No attendance records for today'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.teamAttendance.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = state.teamAttendance[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(record.employeeName.isNotEmpty ? record.employeeName[0] : '?')),
                  title: Text(record.employeeName),
                  subtitle: Text(
                    record.clockInTime != null
                        ? 'In: ${DateFormat.Hm().format(record.clockInTime!)}'
                            '${record.clockOutTime != null ? '  •  Out: ${DateFormat.Hm().format(record.clockOutTime!)}' : ''}'
                        : 'Not clocked in',
                  ),
                  trailing: Chip(label: Text(record.status.name)),
                  onTap: permissions.canEditAttendanceRecords
                      ? () => _showEditDialog(context, record)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, AttendanceEntity record) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit record — ${record.employeeName}'),
          content: const Text(
            'Hook up a real form here (status dropdown, clock-in/out time '
            'pickers, note field). On submit, dispatch:\n\n'
            'AttendanceRecordUpdateRequested(updatedRecord)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
