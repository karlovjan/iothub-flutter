import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iothub/models/Sensor.dart';



abstract class SensorFB extends Sensor {

  DocumentReference reference;

  SensorFB(DateTime created, {this.reference}) : super(created);

  SensorFB fromJson(Map<dynamic, dynamic> json);

  Map<String, dynamic> toJson();

}