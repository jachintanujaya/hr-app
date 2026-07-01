import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Replaces AuthRemoteDataSourceImpl (Dio).
/// Firebase Auth handles token storage and refresh natively — no manual
/// token management needed.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<UserModel> _userFromUid(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw ServerException('User profile not found in Firestore', statusCode: 404);
    }
    return UserModel.fromJson({'id': uid, ...doc.data()!});
  }

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromUid(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw AuthException('Invalid email or password');
      }
      throw ServerException(e.message ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw UnauthorizedException();
    // Re-fetch profile to pick up any role changes made server-side.
    return _userFromUid(user.uid);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}