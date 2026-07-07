import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_entity.dart';
import '../entities/working_hours_settings_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity>> clockIn({String? note});
  Future<Either<Failure, AttendanceEntity>> clockOut({String? note});

  Future<Either<Failure, List<AttendanceEntity>>> getMyAttendance({
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, List<AttendanceEntity>>> getTeamAttendance({
    required DateTime from,
    required DateTime to,
  });

  Future<Either<Failure, AttendanceEntity>> updateAttendanceRecord(AttendanceEntity record);

  /// Live-updating version of [getMyAttendance] — emits a new list whenever
  /// matching Firestore documents change. No manual refresh needed.
  Stream<Either<Failure, List<AttendanceEntity>>> watchMyAttendance({
    required DateTime from,
    required DateTime to,
  });

  /// Org-wide standard working hours. Readable by everyone, writable only
  /// by Super Admin.
  Future<Either<Failure, WorkingHoursSettingsEntity>> getWorkingHoursSettings();
  Future<Either<Failure, WorkingHoursSettingsEntity>> updateWorkingHoursSettings(
      WorkingHoursSettingsEntity settings);
}
