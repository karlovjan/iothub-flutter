import 'package:flutter/foundation.dart';

import 'measured_property.dart';

@immutable
class Measurement<T> {
  final MeasuredProperty property;
  final T value;

  Measurement(this.property, this.value);
}
