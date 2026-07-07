import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/working_hours_settings_entity.dart';
import '../bloc/attendance_bloc.dart';

/// Super Admin (HR) only — configures the org-wide DEFAULT working hours
/// used as a fallback when an employee has no active
/// WorkingHoursPolicy assignment (see features/working_hours/ for the
/// per-employee, date-ranged policy assignments like WFO/WFC).
class WorkingHoursSettingsPage extends StatefulWidget {
  const WorkingHoursSettingsPage({super.key});

  @override
  State<WorkingHoursSettingsPage> createState() => _WorkingHoursSettingsPageState();
}

class _WorkingHoursSettingsPageState extends State<WorkingHoursSettingsPage> {
  final _hoursController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const WorkingHoursSettingsRequested());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _populateIfNeeded(WorkingHoursSettingsEntity settings) {
    if (_initialized) return;
    _hoursController.text = settings.standardHoursPerDay.toStringAsFixed(1);
    _startTime = _parseTime(settings.workStartTime);
    _endTime = _parseTime(settings.workEndTime);
    _initialized = true;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _save() {
    final hours = double.tryParse(_hoursController.text);
    if (hours == null || hours <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid number of hours')));
      return;
    }
    context.read<AttendanceBloc>().add(WorkingHoursSettingsUpdateRequested(
          WorkingHoursSettingsEntity(
            standardHoursPerDay: hours,
            workStartTime: _formatTime(_startTime),
            workEndTime: _formatTime(_endTime),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final permissions = context.watch<AuthBloc>().state.permissions;

    if (permissions == null || !permissions.canManageWorkingHoursSettings) {
      return const Scaffold(body: Center(child: Text("You don't have access to this page")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Default Working Hours')),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state.status == AttendanceStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == AttendanceStatusFlag.actionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Working hours updated')));
          }
        },
        builder: (context, state) {
          final settings = state.workingHoursSettings;
          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _populateIfNeeded(settings);

          final isSaving = state.status == AttendanceStatusFlag.actionInProgress;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'This is the fallback target used for employees who don\'t have '
                'a specific Working Hours Policy (e.g. WFO/WFC) assigned to them.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Standard hours per day',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Work start time'),
                subtitle: Text(_startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(isStart: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Work end time'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(isStart: false),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSaving ? null : _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: isSaving
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
