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

  static Future<UserState> currentUser(UserState userState) async {
    final currentUser = await userState._authRepository.currentUser();
    return userState.copyWith(
      user: currentUser,
    );
  }

  static Future<UserState> signInWithEmailAndPassword(
      UserState userState, String email, String password) async {
    final user = await userState._authRepository.signInWithEmailAndPassword(
      email,
      password,
    );
    return userState.copyWith(user: user);
  }

  static Future<UserState> signOut(UserState userState) async {
    await userState._authRepository.signOut();
    return userState.copyWith(user: User());
  }

  UserState copyWith({AuthRepository authRepository, User user}) {
    return UserState(user ?? _user, authRepository ?? _authRepository);
  }

  void dispose(){
    signOut(this);
  }
}
