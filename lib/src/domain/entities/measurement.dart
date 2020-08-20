import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'measured_property.dart';

@immutable
class Measurement<T> {
  final MeasuredProperty property;
  final T value;

  final DateTime createdAt;

  Measurement(this.property, this.value, {DateTime newCreatedAt})
      : createdAt = newCreatedAt ?? DateTime.now();

  static Measurement fromJson(
      Map<String, dynamic> data, MeasuredProperty deviceMeasuredProperty) {
    final value = '${data[deviceMeasuredProperty.name]}';
    final dt = DateTime.parse(data['createdAt'] as String);

    final intValue = int.tryParse(value);
    if (intValue != null) {
      return Measurement<int>(
          MeasuredProperty.copyOf(deviceMeasuredProperty), intValue,
          newCreatedAt: dt);
    }

    final doubleValue = double.tryParse(value);
    if (doubleValue != null) {
      return Measurement<double>(
          MeasuredProperty.copyOf(deviceMeasuredProperty), doubleValue,
          newCreatedAt: dt);
    }

    return Measurement<String>(
        MeasuredProperty.copyOf(deviceMeasuredProperty), value,
        newCreatedAt: dt);
  }
}
