import 'package:flutter/foundation.dart';

@immutable
class User {
  final String uid;
  final String email;
  final String displayName;

  User({
    required this.uid,
    required this.email,
    required this.displayName
  });

  User copyWith({
    String? uid,
    String? email,
    String? displayName
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String
    );
  }

}

@immutable
class LoggedOutUser extends User {
  LoggedOutUser() : super(email: '', displayName: '', uid:  '');
}

class UserParam {
  final String? email;
  final String? password;
  final SignIn signIn;
  UserParam({
    this.email,
    this.password,
    required this.signIn,
  });
}

enum SignIn {
  withEmailAndPassword
}