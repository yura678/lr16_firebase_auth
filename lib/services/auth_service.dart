import 'package:firebase_auth/firebase_auth.dart';

export 'package:firebase_auth/firebase_auth.dart' show User;

/// Wraps [FirebaseAuth] so screens never touch `FirebaseAuth.instance`
/// directly — mirroring [FirestoreService] / [StorageService].
///
/// Methods let the underlying `FirebaseAuthException` propagate; the UI turns it
/// into a message with `describeError()`.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
