import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class IOTHub {
  final String id;
  final String name;

//  final List<String> gps;
  final GeoPoint? gps;
  final DateTime createdAt;

  IOTHub(this.id, this.name, {this.gps, DateTime? newCreatedAt}) : createdAt = newCreatedAt ?? DateTime.now();

  factory IOTHub.fromJson(Map<String, dynamic> map, String documentID) {
    return IOTHub(
      documentID,
      map['name'] as String,
      gps: map['gps'] as GeoPoint?,
      newCreatedAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IOTHub &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'IOTHub{id: $id, name: $name, gps: $gps, createdAt: $createdAt}';
  }
}
