import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // -----------------------------
  // State
  // -----------------------------
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // -----------------------------
  // Anonymous Login
  // -----------------------------
  Future<User> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    return credential.user!;
  }

  // -----------------------------
  // Logout
  // -----------------------------
  Future<void> signOut() => _auth.signOut();

  // -----------------------------
  // Delete Account
  // -----------------------------
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }
}
