import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employee_model.dart';

/// Firestore schema
/// ─────────────────────────────────────────────────────────────────────────
/// users/{uid}
///   id          : String  (= uid, also the Firebase Auth uid)
///   full_name   : String
///   email       : String
///   phone       : String | null
///   role        : String  ('employee' | 'admin' | 'superAdmin')
///   manager_id  : String | null
///   manager_name: String | null
///   department  : String | null
///   job_title   : String | null
///   hire_date   : Timestamp | null
///   status      : String  ('active' | 'onLeave' | 'suspended' | 'terminated')
///   avatar_url  : String | null
/// ─────────────────────────────────────────────────────────────────────────
abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getTeamMembers();
  Future<List<EmployeeModel>> getAllEmployees({String? searchQuery});
  Future<EmployeeModel> getEmployeeById(String id);
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String id);
  Future<EmployeeModel> reassignRoleOrManager({
    required String employeeId,
    String? newRole,
    String? newManagerId,
  });
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EmployeeRemoteDataSourceImpl({
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

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  EmployeeModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EmployeeModel.fromJson({
      'id': doc.id,
      ...data,
      // Firestore Timestamp → ISO string for hireDate
      if (data['hire_date'] != null)
        'hire_date': (data['hire_date'] as Timestamp).toDate().toIso8601String(),
    });
  }

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<List<EmployeeModel>> getTeamMembers() async {
    final uid = _currentUser.uid;
    final snap = await _users.where('manager_id', isEqualTo: uid).get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<List<EmployeeModel>> getAllEmployees({String? searchQuery}) async {
    // Firestore doesn't support full-text search natively.
    // For production, use Algolia/Typesense or Firebase Extensions.
    // Here we do a client-side filter on the full list, which is fine for
    // small orgs (<1 000 employees). Replace with a proper search index at scale.
    final snap = await _users.get();
    final all = snap.docs.map(_fromDoc).toList();
    if (searchQuery == null || searchQuery.isEmpty) return all;
    final q = searchQuery.toLowerCase();
    return all.where((e) {
      return e.fullName.toLowerCase().contains(q) || e.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<EmployeeModel> getEmployeeById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw ServerException('Employee not found', statusCode: 404);
    }
    return _fromDoc(doc);
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    // NOTE: This creates a Firestore profile only.
    // To also create a Firebase Auth account, use the Admin SDK server-side
    // (e.g. via a Cloud Function triggered on this write), so the new employee
    // can log in with email + a temporary password.
    final docRef = _users.doc(); // auto-generated uid
    final data = {
      'full_name': employee.fullName,
      'email': employee.email,
      'phone': employee.phone,
      'role': employee.role.name,
      'manager_id': employee.managerId,
      'manager_name': employee.managerName,
      'department': employee.department,
      'job_title': employee.jobTitle,
      'hire_date': employee.hireDate != null
          ? Timestamp.fromDate(employee.hireDate!)
          : null,
      'status': employee.status.name,
      'avatar_url': employee.avatarUrl,
    };
    await docRef.set(data);
    final snap = await docRef.get();
    return _fromDoc(snap);
  }

  @override
  Future<EmployeeModel> updateEmployee(EmployeeModel employee) async {
    final data = <String, dynamic>{
      'full_name': employee.fullName,
      'email': employee.email,
      'phone': employee.phone,
      'department': employee.department,
      'job_title': employee.jobTitle,
      'status': employee.status.name,
      if (employee.hireDate != null)
        'hire_date': Timestamp.fromDate(employee.hireDate!),
    };
    await _users.doc(employee.id).update(data);
    final snap = await _users.doc(employee.id).get();
    return _fromDoc(snap);
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await _users.doc(id).delete();
    // NOTE: Deleting the Firebase Auth account also requires the Admin SDK
    // (Cloud Function). Add a Firestore trigger on users/{uid} deletion to
    // call admin.auth().deleteUser(uid) server-side.
  }

  @override
  Future<EmployeeModel> reassignRoleOrManager({
    required String employeeId,
    String? newRole,
    String? newManagerId,
  }) async {
    final updates = <String, dynamic>{};
    if (newRole != null) updates['role'] = newRole;
    if (newManagerId != null) {
      updates['manager_id'] = newManagerId;
      // Fetch manager name for denormalization.
      final managerDoc = await _users.doc(newManagerId).get();
      updates['manager_name'] = managerDoc.data()?['full_name'] ?? '';
    }
    await _users.doc(employeeId).update(updates);
    final snap = await _users.doc(employeeId).get();
    return _fromDoc(snap);
  }
}