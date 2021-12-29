import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

@immutable
class User extends Equatable {
  final String uid;
  final String email;
  final String displayName;

  const User({
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

  @override
  List<Object> get props => [uid, email, displayName];

  @override
  bool get stringify => true;
}

@immutable
class LoggedOutUser extends User {
  const LoggedOutUser() : super(email: '', displayName: '', uid:  '');
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