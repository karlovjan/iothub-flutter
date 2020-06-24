import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/SensorFB.dart';
import '../models/WirelessSensor.dart';

class AqaraTemperatureSensor  {

  double temperature;
  double humidity;
  double pressure;


  AqaraTemperatureSensor(this.temperature, this.humidity, this.pressure);

}