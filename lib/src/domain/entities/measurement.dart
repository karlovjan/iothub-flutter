import 'package:flutter/foundation.dart';

import 'measured_property.dart';

@immutable
class Measurement<T> {
  final MeasuredProperty property;
  final T value;

  Measurement(this.property, this.value);

  static Measurement fromJson(
      Map<String, dynamic> data, MeasuredProperty deviceMeasuredProperty) {
    final value = data[deviceMeasuredProperty.name] as String;

    final intValue = int.tryParse(value);
    if(intValue != null){
      return Measurement<int>(
        MeasuredProperty.copyOf(deviceMeasuredProperty),
        intValue,
      );
    }

    final doubleValue = double.tryParse(value);
    if(doubleValue != null){
      return Measurement<double>(
        MeasuredProperty.copyOf(deviceMeasuredProperty),
        doubleValue,
      );
    }

    return Measurement<String>(
      MeasuredProperty.copyOf(deviceMeasuredProperty),
      value,
    );

  }
}
