import 'package:flutter/foundation.dart';

@immutable
class MeasuredProperty {
  final String name;
  final String unit;
  final String description;
  final DateTime createdAt;

  MeasuredProperty(this.name, this.unit, {this.description, this.createdAt});
}
