import 'package:flutter/foundation.dart';
import 'package:iothub/src/models/Measurement.dart';

abstract class Sensor {

  DateTime createdAt;
  String name;
  String description;
  List<Measurement> measurements;

  Sensor(this.name, this.createdAt, {this.description}) : assert(name != null), assert(createdAt != null);

}