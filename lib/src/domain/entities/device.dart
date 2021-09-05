import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'measured_property.dart';

@immutable
class Device {
  final String id;
  final String name;
  final String? description;
  final String? model;
  final String? vendor;
  final DateTime created;

  final List<MeasuredProperty> _properties;

  final String? typeRef;

  Device(this.id, this.name,
      {this.description,
      this.model,
      this.vendor,
      this.typeRef,
      List<MeasuredProperty>? properties,
      DateTime? newCreatedAt})
      : created = newCreatedAt ?? DateTime.now(),
        _properties = properties ?? [];

  factory Device.fromJson(Map<String, dynamic> map, String documentID) {
    return Device(
      documentID,
      map['name'] as String,
      description: map['description'] as String?,
      model: map['model'] as String?,
      vendor: map['vendor'] as String?,
      typeRef: map['typeRef'] as String?,
      newCreatedAt: (map['created'] as Timestamp).toDate(),
    );
  }

  List<MeasuredProperty> get properties => List.unmodifiable(_properties);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Device && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Device{id: $id, name: $name, description: $description, model: $model, vendor: $vendor, created: $created, _properties: $_properties, typeRef: $typeRef}';
  }
}
