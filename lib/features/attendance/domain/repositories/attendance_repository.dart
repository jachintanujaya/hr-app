import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  /// Clock in the currently logged-in employee. Backend determines employeeId from auth token.
  Future<Either<Failure, AttendanceEntity>> clockIn({String? note});

  /// Clock out the currently logged-in employee.
  Future<Either<Failure, AttendanceEntity>> clockOut({String? note});

  /// The logged-in user's own attendance history within a date range.
  Future<Either<Failure, List<AttendanceEntity>>> getMyAttendance({
    required DateTime from,
    required DateTime to,
  });

  /// Admin/Super Admin only: attendance for everyone reporting to the current admin.
  Future<Either<Failure, List<AttendanceEntity>>> getTeamAttendance({
    required DateTime from,
    required DateTime to,
  });

  /// Admin/Super Admin only: correct an attendance record (e.g. forgot to clock out).
  Future<Either<Failure, AttendanceEntity>> updateAttendanceRecord(AttendanceEntity record);
}
