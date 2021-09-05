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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasuredProperty && runtimeType == other.runtimeType && name == other.name && unit == other.unit;

  @override
  int get hashCode => name.hashCode ^ unit.hashCode;

  @override
  String toString() {
    return 'MeasuredProperty{name: $name, unit: $unit, description: $description, createdAt: $createdAt}';
  }
}
