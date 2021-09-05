import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'measured_property.dart';

@immutable
class Measurement<T> {
  final MeasuredProperty property;
  final T value;

  final DateTime createdAt;

  Measurement(this.property, this.value, {DateTime? newCreatedAt})
      : createdAt = newCreatedAt ?? DateTime.now();

  static Measurement fromJson(
      Map<String, dynamic> data, MeasuredProperty deviceMeasuredProperty) {
    final value = '${data[deviceMeasuredProperty.name]}';
    DateTime? createdAt;
    try {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else {
        final sDateTime = data['createdAt'] as String;
        createdAt = DateFormat('EEE MMM d yyyy HH:mm:ss').parse(sDateTime);
      }
    } catch (e){
      print(e);
    }

    final intValue = int.tryParse(value);
    if (intValue != null) {
      return Measurement<int>(
          MeasuredProperty.copyOf(deviceMeasuredProperty), intValue,
          newCreatedAt: createdAt);
    }

    final doubleValue = double.tryParse(value);
    if (doubleValue != null) {
      return Measurement<double>(
          MeasuredProperty.copyOf(deviceMeasuredProperty), doubleValue,
          newCreatedAt: createdAt);
    }

    return Measurement<String>(
        MeasuredProperty.copyOf(deviceMeasuredProperty), value,
        newCreatedAt: createdAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measurement && runtimeType == other.runtimeType && property == other.property && value == other.value;

  @override
  int get hashCode => property.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'Measurement{property: $property, value: $value, createdAt: $createdAt}';
  }
}
