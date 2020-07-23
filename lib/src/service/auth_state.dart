import 'package:flutter/foundation.dart';
import '../service/interfaces/auth_repository.dart';
import '../domain/entities/user.dart';

@immutable
class UserState {
  final User _user;
  final AuthRepository _authRepository;

  UserState(this._user, this._authRepository)
      : assert(_user != null),
        assert(_authRepository != null);

  User get signedUser =>
      User(uid: _user.uid, email: _user.email, displayName: _user.displayName);

  Future<UserState> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final user = await _authRepository.signInWithEmailAndPassword(
      email,
      password,
    );
    return UserState(user ?? User(), _authRepository);
  }

  Future<UserState> signOut() async {
    await _authRepository.signOut();
    return UserState(User(), _authRepository);
  }
}
