import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../employee_management/presentation/bloc/employee_bloc.dart';
import '../../domain/entities/working_hours_assignment_entity.dart';
import '../../domain/entities/working_hours_policy_entity.dart';
import '../bloc/working_hours_bloc.dart';

/// Super Admin only — assign a policy to a group of employees for a date
/// range, and view who's currently/upcoming assigned vs history.
class AssignPolicyPage extends StatefulWidget {
  final WorkingHoursPolicyEntity policy;
  const AssignPolicyPage({super.key, required this.policy});

  @override
  State<AssignPolicyPage> createState() => _AssignPolicyPageState();
}

class _AssignPolicyPageState extends State<AssignPolicyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedEmployeeIds = {};
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<WorkingHoursBloc>().add(AssignmentsWatchStarted(widget.policy.id));
    context.read<EmployeeBloc>().add(const AllEmployeesRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _start != null && _end != null
          ? DateTimeRange(start: _start!, end: _end!)
          : null,
    );
    if (range != null) {
      setState(() {
        _start = range.start;
        _end = range.end;
      });
    }
  }

  void _submit() {
    if (_selectedEmployeeIds.isEmpty || _start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one employee and a date range')),
      );
      return;
    }
    final employeeState = context.read<EmployeeBloc>().state;
    final names = {
      for (final e in employeeState.allEmployees)
        if (_selectedEmployeeIds.contains(e.id)) e.id: e.fullName
    };

    context.read<WorkingHoursBloc>().add(PolicyAssignRequested(
          policy: widget.policy,
          employees: names,
          start: _start!,
          end: _end!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign ${widget.policy.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Assign'), Tab(text: 'Active / History')],
        ),
      ),
      body: BlocConsumer<WorkingHoursBloc, WorkingHoursState>(
        listener: (context, state) {
          if (state.status == WorkingHoursStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.status == WorkingHoursStatusFlag.actionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Assigned successfully')));
            setState(() {
              _selectedEmployeeIds.clear();
              _start = null;
              _end = null;
            });
          }
        },
        builder: (context, state) {
          final isSaving = state.status == WorkingHoursStatusFlag.actionInProgress;

          return TabBarView(
            controller: _tabController,
            children: [
              // ── Assign tab ─────────────────────────────────────────────
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_start == null
                          ? 'Select date range'
                          : '${dateFmt.format(_start!)} - ${dateFmt.format(_end!)}'),
                      onPressed: _pickRange,
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<EmployeeBloc, EmployeeState>(
                      builder: (context, empState) {
                        if (empState.status == EmployeeStatusFlag.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ListView(
                          children: empState.allEmployees.map((e) {
                            return CheckboxListTile(
                              title: Text(e.fullName),
                              subtitle: Text(e.jobTitle ?? e.email),
                              value: _selectedEmployeeIds.contains(e.id),
                              onChanged: (checked) => setState(() {
                                if (checked ?? false) {
                                  _selectedEmployeeIds.add(e.id);
                                } else {
                                  _selectedEmployeeIds.remove(e.id);
                                }
                              }),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed: isSaving ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: isSaving
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Assign to ${_selectedEmployeeIds.length} employee(s)'),
                    ),
                  ),
                ],
              ),

              // ── Active / History tab ──────────────────────────────────
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Active / Upcoming', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (state.activeOrUpcoming.isEmpty) const Text('None'),
                  ...state.activeOrUpcoming.map((a) => _AssignmentTile(a: a, dateFmt: dateFmt)),
                  const SizedBox(height: 24),
                  Text('History', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (state.history.isEmpty) const Text('None'),
                  ...state.history.map((a) => _AssignmentTile(a: a, dateFmt: dateFmt, isPast: true)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final WorkingHoursAssignmentEntity a;
  final DateFormat dateFmt;
  final bool isPast;
  const _AssignmentTile({required this.a, required this.dateFmt, this.isPast = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(a.employeeName),
        subtitle: Text('${dateFmt.format(a.startDate)} - ${dateFmt.format(a.endDate)}'),
        trailing: Chip(
          label: Text(isPast ? 'Ended' : (a.isActiveToday ? 'Active' : 'Upcoming')),
          backgroundColor: isPast
              ? Colors.grey.withOpacity(0.2)
              : (a.isActiveToday ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15)),
        ),
      ),
    );
  }
}
