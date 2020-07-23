import 'package:flutter/foundation.dart';

@immutable
class User {
  final String uid;
  final String email;
  final String displayName;

  User({
    this.uid,
    this.email,
    this.displayName
  });

  User copyWith({
    String uid,
    String email,
    String displayName
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return User(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String
    );
  }

}