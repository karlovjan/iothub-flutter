import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iothub/models/Sensor.dart';


SensorFB _sensorFBFromJson(Map<dynamic, dynamic> json) {
  return SensorFB(
    json['name'] as String,
    json['created'] == null ? null : (json['created'] as Timestamp).toDate(),
    modified: json['modified'] == null ? null : (json['modified'] as Timestamp).toDate(),
  );
}

Map<String, dynamic> _sensorFBToJson(SensorFB instance) =>
    <String, dynamic> {
      'name': instance.name,
      'created': instance.created,
      'modified': instance.modified,
    };


class SensorFB extends Sensor{

  DocumentReference reference;

  SensorFB(String name, DateTime created, {DateTime modified, this.reference}) : super(name, created, modified: modified);

  factory SensorFB.fromJson(Map<dynamic, dynamic> json) => _sensorFBFromJson(json);

  Map<String, dynamic> toJson() => _sensorFBToJson(this);

  @override
  String toString() {
    return 'SensorFB{name: $name}';
  }
}