import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/attendance_bloc.dart';

/// Attendance history for the logged-in user, filtered by month (defaults
/// to the current month) and kept live via a Firestore stream — no manual
/// refresh needed. Clocking in/out happens from the dashboard.
class ClockInOutPage extends StatefulWidget {
  const ClockInOutPage({super.key});

  @override
  State<ClockInOutPage> createState() => _ClockInOutPageState();
}

class _ClockInOutPageState extends State<ClockInOutPage> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    context.read<AttendanceBloc>().add(MyAttendanceMonthChanged(_month));
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _changeMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _month = next);
    context.read<AttendanceBloc>().add(MyAttendanceMonthChanged(_month));
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    int selectedYear = _month.year;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setDialogState(() => selectedYear--),
                  ),
                  Text('$selectedYear'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        selectedYear >= now.year ? null : () => setDialogState(() => selectedYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: 280,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  childAspectRatio: 2,
                  children: List.generate(12, (i) {
                    final monthNum = i + 1;
                    final isFuture = selectedYear == now.year && monthNum > now.month;
                    return TextButton(
                      onPressed: isFuture
                          ? null
                          : () => Navigator.of(dialogContext).pop(DateTime(selectedYear, monthNum)),
                      child: Text(DateFormat('MMM').format(DateTime(selectedYear, monthNum))),
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() => _month = picked);
      context.read<AttendanceBloc>().add(MyAttendanceMonthChanged(_month));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                TextButton(
                  onPressed: _pickMonth,
                  child: Text(
                    DateFormat('MMMM yyyy').format(_month),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _isCurrentMonth ? null : () => _changeMonth(1),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
                if (state.status == AttendanceStatusFlag.failure && state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                }
              },
              builder: (context, state) {
                final isLoading = (state.status == AttendanceStatusFlag.loading ||
                        state.status == AttendanceStatusFlag.initial) &&
                    state.myAttendance.isEmpty;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = [...state.myAttendance]..sort((a, b) => b.date.compareTo(a.date));

                if (records.isEmpty) {
                  return const Center(child: Text('No attendance records for this month'));
                }

                final dateFmt = DateFormat('EEE, MMM d');
                final timeFmt = DateFormat.Hm();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Clock In')),
                        DataColumn(label: Text('Clock Out')),
                        DataColumn(label: Text('Working Hours')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: records.map((record) {
                        final worked = record.workedDuration;
                        final workedLabel =
                            worked == null ? '—' : '${worked.inHours}h ${worked.inMinutes % 60}m';

                        return DataRow(cells: [
                          DataCell(Text(dateFmt.format(record.date))),
                          DataCell(Text(
                              record.clockInTime != null ? timeFmt.format(record.clockInTime!) : '—')),
                          DataCell(Text(record.clockOutTime != null
                              ? timeFmt.format(record.clockOutTime!)
                              : '—')),
                          DataCell(Text(workedLabel)),
                          DataCell(Chip(label: Text(record.status.name))),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
