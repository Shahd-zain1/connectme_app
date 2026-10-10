import 'package:firebase_auth/firebase_auth.dart';

import '../core/errors/failures.dart';

// Wraps FirebaseAuth so nothing outside this file ever sees Firebase's
// own User type (which would also clash with our domain User entity),
// callers get a plain record with just the uid and email, and every
// error comes back as a Failure with a user-facing message.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  // AuthCubit listens to this to decide between the login screen and the
  // home feed. FirebaseAuth already persists the session across app
  // restarts on its own, so this stream emits the signed-in user right
  // away on launch if there is one, which is what skips the login screen.
  Stream<({String uid, String? email})?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (user) => user == null ? null : (uid: user.uid, email: user.email),
        );
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      throw Failure(_messageForAuthError(error));
    }
  }

  Future<String> signUp({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.uid;
    } on FirebaseAuthException catch (error) {
      throw Failure(_messageForAuthError(error));
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  String _messageForAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'That password is too weak, try a longer one.';
      case 'network-request-failed':
        return 'Could not reach the server. Check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
