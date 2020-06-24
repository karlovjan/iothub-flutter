import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/SensorFB.dart';

abstract class WirelessSensor {
  int batteryCapacity;
  int linkQuality;

  WirelessSensor(String name, DateTime createdAt, {String description, this.batteryCapacity, this.linkQuality, DocumentReference reference});


}