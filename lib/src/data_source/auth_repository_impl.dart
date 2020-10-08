import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../domain/entities/user.dart' as iothub_user;
import '../service/exceptions/auth_exception.dart';
import '../service/interfaces/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {


  FirebaseAuthRepository({FirebaseAuth firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;


  @override
  Future<iothub_user.User> createUserWithEmailAndPassword(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<iothub_user.User> currentUser() async {
    final firebaseUser = await _auth.currentUser;
    return _fromFireBaseUserToUser(firebaseUser);
  }

  @override
  Future<iothub_user.User> signInWithEmailAndPassword(String email, String password) async {
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

  iothub_user.User _fromFireBaseUserToUser(User user) {
    if (user == null) {
      return iothub_user.User();
    }
    return iothub_user.User(
        uid: user.uid, email: user.email, displayName: user.displayName);
  }

}
