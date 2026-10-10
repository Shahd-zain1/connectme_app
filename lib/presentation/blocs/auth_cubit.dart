import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_builder.dart';
import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final User user;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}

// Owns who's signed in. It listens to AuthService's auth state stream,
// so if a session already exists when the app launches, the first event
// is that signed-in user and the login screen is skipped, no manual
// "check if logged in" step needed.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService, this._userProfileService) : super(const AuthInitial()) {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  final UserProfileService _userProfileService;
  late final StreamSubscription<({String uid, String? email})?> _authSubscription;

  // While sign-up is running, the stream fires as soon as the Firebase
  // account exists, before the profile document is saved, so the stream
  // handler steps aside and signUp emits the final state itself. Without
  // this the handler could fetch a profile that isn't saved yet.
  bool _isSigningUp = false;

  Future<void> _onAuthStateChanged(({String uid, String? email})? firebaseUser) async {
    if (_isSigningUp) return;

    if (firebaseUser == null) {
      emit(const Unauthenticated());
      return;
    }

    try {
      final profile = await _userProfileService.fetchProfile(firebaseUser.uid);
      emit(Authenticated(profile ?? _minimalUser(firebaseUser)));
    } on Failure {
      emit(Authenticated(_minimalUser(firebaseUser)));
    }
  }

  // Builder Pattern: a user with a Firebase account but no saved profile
  // document yet only gets the fields we actually know.
  User _minimalUser(({String uid, String? email}) firebaseUser) {
    final builder = UserBuilder(firebaseUser.uid);
    final email = firebaseUser.email;
    if (email != null) builder.setEmail(email);
    return builder.build();
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      await _authService.signIn(email: email, password: password);
    } on Failure catch (failure) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    _isSigningUp = true;
    try {
      final uid = await _authService.signUp(email: email, password: password);

      // Builder Pattern: only the fields sign-up actually collected get
      // set. Photo and device info stay unset until ProfileCubit adds them.
      final user = UserBuilder(uid).setFullName(fullName).setEmail(email).build();

      try {
        await _userProfileService.saveProfile(user);
      } on Failure {
        // The account exists either way. If this save failed, the name is
        // still in memory here and gets saved along with the next profile
        // update, so it isn't lost.
      }
      emit(Authenticated(user));
    } on Failure catch (failure) {
      emit(AuthError(failure.message));
    } finally {
      _isSigningUp = false;
    }
  }

  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
