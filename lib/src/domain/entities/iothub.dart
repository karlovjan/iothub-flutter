import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'measured_property.dart';

@immutable
class IOTHub {
  final String id;
  final String name;
//  final List<String> gps;
  final GeoPoint gps;
  final DateTime createdAt;

  IOTHub(this.name, {this.id, this.gps, DateTime newCreatedAt})
      : assert(name != null),
        createdAt = newCreatedAt ?? DateTime.now();


  factory IOTHub.fromJson(Map<String, dynamic> map) {
    return IOTHub(
      map['name'] as String,
      id: map['id'] as String,
      gps: map['gps'] as GeoPoint,
      newCreatedAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
