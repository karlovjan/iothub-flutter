import 'package:flutter/foundation.dart';

@immutable
class MeasuredProperty {
  final String name;
  final String unit;
  final String? description;
  final DateTime? createdAt;

  MeasuredProperty(this.name, this.unit, {this.description, this.createdAt});

  static MeasuredProperty copyOf(MeasuredProperty measuredProperty) {
    return MeasuredProperty(
      measuredProperty.name,
      measuredProperty.unit,
      description: measuredProperty.description,
      createdAt: measuredProperty.createdAt,
    );
  }
}
