import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/time_off_balance_model.dart';
import '../models/time_off_policy_model.dart';
import '../models/time_off_request_model.dart';

/// Firestore schema
/// ─────────────────────────────────────────────────────────────────────────
/// time_off_requests/{docId}
///   id              : String  (= docId)
///   employee_id     : String
///   employee_name   : String
///   manager_id      : String  (for team queries)
///   type            : String
///   start_date      : Timestamp
///   end_date        : Timestamp
///   reason          : String | null
///   status          : String  ('pending'|'approved'|'rejected'|'cancelled')
///   approver_id     : String | null
///   approver_name   : String | null
///   decision_note   : String | null
///   created_at      : Timestamp
///
/// time_off_balances/{docId}   (one per employee per type, managed server-side
///                              or via Cloud Functions)
///   employee_id     : String
///   type            : String
///   total_days      : number
///   used_days       : number
///
/// time_off_policies/{docId}   (one per TimeOffType, managed by Super Admin)
///   id              : String  (= docId)
///   type            : String
///   annual_allowance_days     : number
///   requires_approval         : bool
///   min_notice_days           : number
///   carries_over_to_next_year : bool
/// ─────────────────────────────────────────────────────────────────────────
abstract class TimeOffRemoteDataSource {
  Future<TimeOffRequestModel> requestTimeOff(TimeOffRequestModel request);
  Future<void> cancelTimeOff(String requestId);
  Future<TimeOffRequestModel> approveTimeOff({required String requestId, String? note});
  Future<TimeOffRequestModel> rejectTimeOff({required String requestId, String? note});
  Future<List<TimeOffRequestModel>> getMyRequests();
  Future<List<TimeOffRequestModel>> getTeamRequests();
  Future<List<TimeOffBalanceModel>> getMyBalances();
  Future<List<TimeOffPolicyModel>> getPolicies();
  Future<TimeOffPolicyModel> updatePolicy(TimeOffPolicyModel policy);
}

class TimeOffRemoteDataSourceImpl implements TimeOffRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TimeOffRemoteDataSourceImpl({
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

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('time_off_requests');
  CollectionReference<Map<String, dynamic>> get _balances =>
      _firestore.collection('time_off_balances');
  CollectionReference<Map<String, dynamic>> get _policies =>
      _firestore.collection('time_off_policies');

  Map<String, dynamic> _normalizeRequest(Map<String, dynamic> data, String id) {
    return {
      'id': id,
      'employee_id': data['employee_id'],
      'employee_name': data['employee_name'] ?? '',
      'type': data['type'] ?? 'other',
      'start_date': _tsToIso(data['start_date']),
      'end_date': _tsToIso(data['end_date']),
      'reason': data['reason'],
      'status': data['status'] ?? 'pending',
      'approver_id': data['approver_id'],
      'approver_name': data['approver_name'],
      'decision_note': data['decision_note'],
      'created_at': _tsToIso(data['created_at']),
    };
  }

  String _tsToIso(dynamic ts) {
    if (ts is Timestamp) return ts.toDate().toIso8601String();
    return ts?.toString() ?? DateTime.now().toIso8601String();
  }

  TimeOffRequestModel _requestFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TimeOffRequestModel.fromJson(_normalizeRequest(doc.data()!, doc.id));
  }

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<TimeOffRequestModel> requestTimeOff(TimeOffRequestModel request) async {
    final user = _currentUser;

    // Fetch employee name & manager_id from Firestore users collection.
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final employeeName = userDoc.data()?['full_name'] as String? ?? '';
    final managerId = userDoc.data()?['manager_id'] as String?;

    final docRef = _requests.doc();
    final data = {
      'employee_id': user.uid,
      'employee_name': employeeName,
      'manager_id': managerId,
      'type': request.type.name,
      'start_date': Timestamp.fromDate(request.startDate),
      'end_date': Timestamp.fromDate(request.endDate),
      'reason': request.reason,
      'status': 'pending',
      'approver_id': null,
      'approver_name': null,
      'decision_note': null,
      'created_at': FieldValue.serverTimestamp(),
    };
    await docRef.set(data);

    final snap = await docRef.get();
    return _requestFromDoc(snap);
  }

  @override
  Future<void> cancelTimeOff(String requestId) async {
    final user = _currentUser;
    final doc = await _requests.doc(requestId).get();
    if (!doc.exists) throw ServerException('Request not found', statusCode: 404);
    if (doc.data()!['employee_id'] != user.uid) {
      throw AuthException('You can only cancel your own requests');
    }
    await _requests.doc(requestId).update({'status': 'cancelled'});
  }

  @override
  Future<TimeOffRequestModel> approveTimeOff({
    required String requestId,
    String? note,
  }) async {
    final user = _currentUser;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final approverName = userDoc.data()?['full_name'] as String? ?? '';

    await _requests.doc(requestId).update({
      'status': 'approved',
      'approver_id': user.uid,
      'approver_name': approverName,
      if (note != null) 'decision_note': note,
    });

    final snap = await _requests.doc(requestId).get();
    return _requestFromDoc(snap);
  }

  @override
  Future<TimeOffRequestModel> rejectTimeOff({
    required String requestId,
    String? note,
  }) async {
    final user = _currentUser;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final approverName = userDoc.data()?['full_name'] as String? ?? '';

    await _requests.doc(requestId).update({
      'status': 'rejected',
      'approver_id': user.uid,
      'approver_name': approverName,
      if (note != null) 'decision_note': note,
    });

    final snap = await _requests.doc(requestId).get();
    return _requestFromDoc(snap);
  }

  @override
  Future<List<TimeOffRequestModel>> getMyRequests() async {
    final user = _currentUser;
    final snap = await _requests
        .where('employee_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map(_requestFromDoc).toList();
  }

  @override
  Future<List<TimeOffRequestModel>> getTeamRequests() async {
    final user = _currentUser;
    // Returns requests from employees whose manager_id == current user's uid.
    final snap = await _requests
        .where('manager_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map(_requestFromDoc).toList();
  }

  @override
  Future<List<TimeOffBalanceModel>> getMyBalances() async {
    final user = _currentUser;
    final snap = await _balances
        .where('employee_id', isEqualTo: user.uid)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return TimeOffBalanceModel.fromJson({
        'type': data['type'],
        'total_days': data['total_days'],
        'used_days': data['used_days'],
      });
    }).toList();
  }

  @override
  Future<List<TimeOffPolicyModel>> getPolicies() async {
    final snap = await _policies.get();
    return snap.docs.map((d) {
      return TimeOffPolicyModel.fromJson({'id': d.id, ...d.data()});
    }).toList();
  }

  @override
  Future<TimeOffPolicyModel> updatePolicy(TimeOffPolicyModel policy) async {
    await _policies.doc(policy.id).set(policy.toJson(), SetOptions(merge: true));
    final snap = await _policies.doc(policy.id).get();
    return TimeOffPolicyModel.fromJson({'id': snap.id, ...snap.data()!});
  }
}