import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../domain/entities/user.dart' as iothub_user;
import 'package:states_rebuilder/states_rebuilder.dart';
import '../service/exceptions/auth_exception.dart';

class FirebaseAuthRepository implements IAuth<iothub_user.User, iothub_user.UserParam> {

  var log = Logger(
    printer: PrettyPrinter(
        methodCount: 2, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 120, // width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
    ),
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  Future<void> init() async {}

  @override
  Future<iothub_user.User> signUp(iothub_user.UserParam? param) {
    throw UnimplementedError();
  }

  @override
  Future<iothub_user.User> signIn(iothub_user.UserParam? param) {
    switch (param!.signIn) {
      case iothub_user.SignIn.withEmailAndPassword:
        return _signInWithEmailAndPassword(
          param.email!,
          param.password!,
        );

      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(iothub_user.UserParam? param) {
    return _firebaseAuth.signOut();
  }

  Future<iothub_user.User> currentUser() async {
    final firebaseUser = await _firebaseAuth.currentUser;
    return _fromFireBaseUserToUser(firebaseUser);
  }

  Future<iothub_user.User> _signInWithEmailAndPassword(String email, String password) async {
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw AuthorizationException(e.message ?? 'Error without message');
      } else {
        rethrow;
      }
    }
  }

  iothub_user.User _fromFireBaseUserToUser(User? user) {
    if (user == null) {
      return iothub_user.LoggedOutUser();
    }
    return iothub_user.User(
        uid: user.uid, email: user.email ?? '', displayName: user.displayName ?? '');
  }

  @override
  void dispose() async {
    log.w('dispose firebase object');
  }

}
