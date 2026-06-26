import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_my_attendance_usecase.dart';
import '../../domain/usecases/get_team_attendance_usecase.dart';
import '../../domain/usecases/update_attendance_record_usecase.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

/// Single bloc serving both the employee clock-in/out screen and the
/// admin/super-admin team-attendance screen. The UI decides which events
/// to dispatch based on Permissions — this bloc doesn't re-check roles
/// itself (the backend is the real enforcement point; see repository).
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ClockInUseCase clockInUseCase;
  final ClockOutUseCase clockOutUseCase;
  final GetMyAttendanceUseCase getMyAttendanceUseCase;
  final GetTeamAttendanceUseCase getTeamAttendanceUseCase;
  final UpdateAttendanceRecordUseCase updateAttendanceRecordUseCase;

  AttendanceBloc({
    required this.clockInUseCase,
    required this.clockOutUseCase,
    required this.getMyAttendanceUseCase,
    required this.getTeamAttendanceUseCase,
    required this.updateAttendanceRecordUseCase,
  }) : super(const AttendanceState()) {
    on<MyAttendanceRequested>(_onMyAttendanceRequested);
    on<ClockInRequested>(_onClockInRequested);
    on<ClockOutRequested>(_onClockOutRequested);
    on<TeamAttendanceRequested>(_onTeamAttendanceRequested);
    on<AttendanceRecordUpdateRequested>(_onRecordUpdateRequested);
  }

  Future<void> _onMyAttendanceRequested(
    MyAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatusFlag.loading));
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    final result = await getMyAttendanceUseCase(DateRangeParams(from: from, to: now));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceStatusFlag.failure,
        errorMessage: failure.message,
      )),
      (records) {
        final today = DateTime(now.year, now.month, now.day);
        AttendanceEntity? todayRecord;
        for (final r in records) {
          final d = DateTime(r.date.year, r.date.month, r.date.day);
          if (d == today) {
            todayRecord = r;
            break;
          }
        }
        emit(state.copyWith(
          status: AttendanceStatusFlag.loaded,
          myAttendance: records,
          todayRecord: todayRecord,
        ));
      },
    );
  }

  Future<void> _onClockInRequested(
    ClockInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatusFlag.actionInProgress));
    final result = await clockInUseCase(ClockInParams(note: event.note));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceStatusFlag.failure,
        errorMessage: failure.message,
      )),
      (record) => emit(state.copyWith(
        status: AttendanceStatusFlag.loaded,
        todayRecord: record,
      )),
    );
  }

  Future<void> _onClockOutRequested(
    ClockOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatusFlag.actionInProgress));
    final result = await clockOutUseCase(ClockOutParams(note: event.note));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceStatusFlag.failure,
        errorMessage: failure.message,
      )),
      (record) => emit(state.copyWith(
        status: AttendanceStatusFlag.loaded,
        todayRecord: record,
      )),
    );
  }

  Future<void> _onTeamAttendanceRequested(
    TeamAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatusFlag.loading));
    final result = await getTeamAttendanceUseCase(
      DateRangeParams(from: event.from, to: event.to),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceStatusFlag.failure,
        errorMessage: failure.message,
      )),
      (records) => emit(state.copyWith(
        status: AttendanceStatusFlag.loaded,
        teamAttendance: records,
      )),
    );
  }

  Future<void> _onRecordUpdateRequested(
    AttendanceRecordUpdateRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatusFlag.actionInProgress));
    final result = await updateAttendanceRecordUseCase(event.record);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceStatusFlag.failure,
        errorMessage: failure.message,
      )),
      (updated) {
        final newList = state.teamAttendance
            .map((r) => r.id == updated.id ? updated : r)
            .toList();
        emit(state.copyWith(
          status: AttendanceStatusFlag.loaded,
          teamAttendance: newList,
        ));
      },
    );
  }
}
