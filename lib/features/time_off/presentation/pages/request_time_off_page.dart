import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/time_off_request_entity.dart';
import '../bloc/time_off_bloc.dart';

class RequestTimeOffPage extends StatefulWidget {
  const RequestTimeOffPage({super.key});

  @override
  State<RequestTimeOffPage> createState() => _RequestTimeOffPageState();
}

class _RequestTimeOffPageState extends State<RequestTimeOffPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  TimeOffType _selectedType = TimeOffType.vacation;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select start and end dates')));
      return;
    }
    context.read<TimeOffBloc>().add(TimeOffRequestSubmitted(
          TimeOffRequestEntity(
            id: '',
            employeeId: '', // backend infers from auth token
            employeeName: '',
            type: _selectedType,
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
            createdAt: DateTime.now(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Request Time Off')),
      body: BlocListener<TimeOffBloc, TimeOffState>(
        listener: (context, state) {
          if (state.status == TimeOffStatusFlag.actionSuccess) {
            Navigator.of(context).pop();
          }
          if (state.status == TimeOffStatusFlag.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<TimeOffType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: TimeOffType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value ?? TimeOffType.vacation),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start date'),
                subtitle: Text(_startDate != null ? dateFmt.format(_startDate!) : 'Select date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End date'),
                subtitle: Text(_endDate != null ? dateFmt.format(_endDate!) : 'Select date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Reason (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              BlocBuilder<TimeOffBloc, TimeOffState>(
                builder: (context, state) {
                  final isSubmitting = state.status == TimeOffStatusFlag.actionInProgress;
                  return FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit Request'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
