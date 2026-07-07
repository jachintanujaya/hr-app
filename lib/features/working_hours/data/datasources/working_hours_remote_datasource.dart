import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/working_hours_assignment_model.dart';
import '../models/working_hours_policy_model.dart';

/// Firestore schema
/// ─────────────────────────────────────────────────────────────────────────
/// working_hours_policies/{policyId}
///   name, start_time, end_time, standard_hours_per_day, created_at
///
/// working_hours_assignments/{assignmentId}   (one doc per employee)
///   policy_id, policy_name, employee_id, employee_name,
///   start_date, end_date, created_at, created_by
/// ─────────────────────────────────────────────────────────────────────────
abstract class WorkingHoursRemoteDataSource {
  Stream<List<WorkingHoursPolicyModel>> watchPolicies();
  Future<WorkingHoursPolicyModel> createPolicy(WorkingHoursPolicyModel policy);
  Future<WorkingHoursPolicyModel?> getPolicyById(String id);
  Stream<List<WorkingHoursAssignmentModel>> watchAssignmentsForPolicy(String policyId);
  Future<List<WorkingHoursAssignmentModel>> getAssignmentsForEmployee(String employeeId);
  Future<void> assignPolicyToEmployees({
    required WorkingHoursPolicyModel policy,
    required Map<String, String> employees,
    required DateTime start,
    required DateTime end,
  });
}

class WorkingHoursRemoteDataSourceImpl implements WorkingHoursRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WorkingHoursRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _policies =>
      _firestore.collection('working_hours_policies');
  CollectionReference<Map<String, dynamic>> get _assignments =>
      _firestore.collection('working_hours_assignments');

  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Not authenticated');
    return user;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _rangesOverlap(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    return !(aEnd.isBefore(bStart) || bEnd.isBefore(aStart));
  }

  @override
  Stream<List<WorkingHoursPolicyModel>> watchPolicies() {
    return _policies.orderBy('created_at', descending: true).snapshots().map((snap) =>
        snap.docs.map((d) => WorkingHoursPolicyModel.fromFirestore(d.id, d.data())).toList());
  }

  @override
  Future<WorkingHoursPolicyModel> createPolicy(WorkingHoursPolicyModel policy) async {
    final docRef = _policies.doc();
    await docRef.set({...policy.toJson(), 'created_at': FieldValue.serverTimestamp()});
    final snap = await docRef.get();
    return WorkingHoursPolicyModel.fromFirestore(snap.id, snap.data()!);
  }

  @override
  Future<WorkingHoursPolicyModel?> getPolicyById(String id) async {
    final doc = await _policies.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return WorkingHoursPolicyModel.fromFirestore(doc.id, doc.data()!);
  }

  @override
  Stream<List<WorkingHoursAssignmentModel>> watchAssignmentsForPolicy(String policyId) {
    return _assignments.where('policy_id', isEqualTo: policyId).snapshots().map((snap) => snap.docs
        .map((d) => WorkingHoursAssignmentModel.fromFirestore(d.id, d.data()))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate)));
  }

  @override
  Future<List<WorkingHoursAssignmentModel>> getAssignmentsForEmployee(String employeeId) async {
    final snap = await _assignments.where('employee_id', isEqualTo: employeeId).get();
    return snap.docs
        .map((d) => WorkingHoursAssignmentModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  @override
  Future<void> assignPolicyToEmployees({
    required WorkingHoursPolicyModel policy,
    required Map<String, String> employees,
    required DateTime start,
    required DateTime end,
  }) async {
    final user = _currentUser;
    final newStart = _dateOnly(start);
    final newEnd = _dateOnly(end);

    // NOTE: overlap validation is client-side, not transactional across
    // employees. Two Super Admins saving at the same instant could both
    // pass this check before either writes. Acceptable for this app's
    // scale; a Cloud Function would be needed to close that race fully.
    final conflicts = <String>[];
    for (final entry in employees.entries) {
      final existing = await getAssignmentsForEmployee(entry.key);
      for (final a in existing) {
        if (_rangesOverlap(a.startDate, a.endDate, newStart, newEnd)) {
          conflicts.add(
              '${entry.value} already has "${a.policyName}" assigned in an overlapping period');
          break;
        }
      }
    }
    if (conflicts.isNotEmpty) {
      throw ServerException(conflicts.join('; '));
    }

    final batch = _firestore.batch();
    for (final entry in employees.entries) {
      final docRef = _assignments.doc();
      batch.set(docRef, {
        'policy_id': policy.id,
        'policy_name': policy.name,
        'employee_id': entry.key,
        'employee_name': entry.value,
        'start_date': Timestamp.fromDate(newStart),
        'end_date': Timestamp.fromDate(newEnd),
        'created_at': FieldValue.serverTimestamp(),
        'created_by': user.uid,
      });
    }
    await batch.commit();
  }
}
