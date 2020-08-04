import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'measured_property.dart';

@immutable
class Device {
  final String id;
  final String name;
  final String description;
  final String model;
  final String vendor;
  final DateTime created;

  final List<MeasuredProperty> _properties;

  final String measurementColl = 'data';

  final String typeRef;

  Device(this.name,
      {this.id,
      this.description,
      this.model,
      this.vendor,
      this.typeRef,
      List<MeasuredProperty> properties,
      DateTime newCreatedAt})
      : assert(name != null),
        created = newCreatedAt ?? DateTime.now(),
        _properties = properties ?? [];

  factory Device.fromJson(Map<String, dynamic> map, String documentID) {
    return Device(
      map['name'] as String,
      id: documentID,
      description: map['description'] as String,
      model: map['model'] as String,
      vendor: map['vendor'] as String,
      typeRef: map['typeRef'] as String,
      newCreatedAt: (map['created'] as Timestamp).toDate(),
    );
  }

  List<MeasuredProperty> get properties => List.unmodifiable(_properties);
}
