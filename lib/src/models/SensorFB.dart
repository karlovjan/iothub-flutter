import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Sensor.dart';



abstract class SensorFB extends Sensor {

  DocumentReference reference;

  SensorFB(String name, DateTime createdAt, {String description, this.reference}) : super(name, createdAt, description: description);

}