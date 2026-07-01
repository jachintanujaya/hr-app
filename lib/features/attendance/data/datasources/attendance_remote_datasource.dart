import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_model.dart';

/// Firestore schema
/// ─────────────────────────────────────────────────────────────────────────
/// attendance/{docId}
///   id             : String  (= docId)
///   employee_id    : String  (= Firebase Auth uid)
///   employee_name  : String
///   date           : Timestamp
///   clock_in_time  : Timestamp | null
///   clock_out_time : Timestamp | null
///   status         : String  ('present' | 'late' | 'absent' | 'onLeave' | 'halfDay')
///   note           : String | null
///   manager_id     : String  (used for team-scoped queries)
/// ─────────────────────────────────────────────────────────────────────────
abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> clockIn({String? note});
  Future<AttendanceModel> clockOut({String? note});
  Future<List<AttendanceModel>> getMyAttendance({required DateTime from, required DateTime to});
  Future<List<AttendanceModel>> getTeamAttendance({required DateTime from, required DateTime to});
  Future<AttendanceModel> updateAttendanceRecord(AttendanceModel record);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AttendanceRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ── helpers ──────────────────────────────────────────────────────────────

  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Not authenticated');
    return user;
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('attendance');

  /// Converts a Firestore document snapshot to AttendanceModel.
  AttendanceModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AttendanceModel.fromJson(_timestampsToIso(data, doc.id));
  }

  /// Firestore returns Timestamps; convert to ISO strings so fromJson works.
  Map<String, dynamic> _timestampsToIso(Map<String, dynamic> data, String id) {
    return {
      'id': id,
      'employee_id': data['employee_id'],
      'employee_name': data['employee_name'] ?? '',
      'date': _tsToIso(data['date']),
      'clock_in_time': data['clock_in_time'] != null ? _tsToIso(data['clock_in_time']) : null,
      'clock_out_time': data['clock_out_time'] != null ? _tsToIso(data['clock_out_time']) : null,
      'status': data['status'] ?? 'present',
      'note': data['note'],
    };
  }

  String _tsToIso(dynamic ts) {
    if (ts is Timestamp) return ts.toDate().toIso8601String();
    return ts.toString();
  }

  /// Returns today's attendance doc for the current user, or null.
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findTodayDoc(String uid) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final snap = await _col
        .where('employee_id', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('date', isLessThan: Timestamp.fromDate(todayEnd))
        .limit(1)
        .get();

    return snap.docs.isEmpty ? null : snap.docs.first;
  }

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<AttendanceModel> clockIn({String? note}) async {
    final user = _currentUser;
    final existing = await _findTodayDoc(user.uid);

    if (existing != null) {
      // Already has a record today — just update clock_in_time if not set.
      final data = existing.data();
      if (data['clock_in_time'] != null) {
        throw ServerException('Already clocked in today');
      }
      await existing.reference.update({'clock_in_time': FieldValue.serverTimestamp()});
      final updated = await existing.reference.get();
      return _fromDoc(updated);
    }

    // Fetch display name from users collection.
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final employeeName = userDoc.data()?['full_name'] as String? ?? user.displayName ?? '';
    final managerId = userDoc.data()?['manager_id'] as String?;

    final now = DateTime.now();
    final docRef = _col.doc();
    await docRef.set({
      'employee_id': user.uid,
      'employee_name': employeeName,
      'manager_id': managerId,
      'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      'clock_in_time': FieldValue.serverTimestamp(),
      'clock_out_time': null,
      'status': 'present',
      'note': note,
    });

    final snap = await docRef.get();
    return _fromDoc(snap);
  }

  @override
  Future<AttendanceModel> clockOut({String? note}) async {
    final user = _currentUser;
    final existing = await _findTodayDoc(user.uid);

    if (existing == null) {
      throw ServerException('No clock-in record found for today');
    }
    if (existing.data()['clock_out_time'] != null) {
      throw ServerException('Already clocked out today');
    }

    final updates = <String, dynamic>{
      'clock_out_time': FieldValue.serverTimestamp(),
    };
    if (note != null) updates['note'] = note;
    await existing.reference.update(updates);

    final updated = await existing.reference.get();
    return _fromDoc(updated);
  }

  @override
  Future<List<AttendanceModel>> getMyAttendance({
    required DateTime from,
    required DateTime to,
  }) async {
    final user = _currentUser;
    final snap = await _col
        .where('employee_id', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('date', descending: true)
        .get();

    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  @override
  Future<List<AttendanceModel>> getTeamAttendance({
    required DateTime from,
    required DateTime to,
  }) async {
    final user = _currentUser;
    // Admin sees records where manager_id == their uid.
    final snap = await _col
        .where('manager_id', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('date', descending: true)
        .get();

    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  @override
  Future<AttendanceModel> updateAttendanceRecord(AttendanceModel record) async {
    final docRef = _col.doc(record.id);
    await docRef.update({
      'clock_in_time': record.clockInTime != null
          ? Timestamp.fromDate(record.clockInTime!)
          : null,
      'clock_out_time': record.clockOutTime != null
          ? Timestamp.fromDate(record.clockOutTime!)
          : null,
      'status': record.status.name,
      'note': record.note,
    });
    final snap = await docRef.get();
    return _fromDoc(snap);
  }
}