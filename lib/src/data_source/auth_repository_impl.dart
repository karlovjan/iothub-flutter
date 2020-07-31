import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../domain/entities/user.dart';
import '../service/exceptions/auth_exception.dart';
import '../service/interfaces/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {


  FirebaseAuthRepository({FirebaseAuth firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;


  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<User> currentUser() async {
    final firebaseUser = await _auth.currentUser();
    return _fromFireBaseUserToUser(firebaseUser);
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw AuthorizationException(e.message);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User _fromFireBaseUserToUser(FirebaseUser user) {
    if (user == null) {
      return User();
    }
    return User(
        uid: user.uid, email: user.email, displayName: user.displayName);
  }

}
