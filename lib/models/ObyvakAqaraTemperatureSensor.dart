import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iothub/models/SensorFB.dart';

class ObyvakAqaraTemperatureSensor extends SensorFB {

  double temperature;
  double humidity;
  double pressure;
  int battery;
  int linkQuality;

  ObyvakAqaraTemperatureSensor(this.temperature, this.humidity, this.pressure, this.battery, this.linkQuality, DateTime created) : super(created);



  @override
  ObyvakAqaraTemperatureSensor fromJson(Map<dynamic, dynamic> json) {
    return ObyvakAqaraTemperatureSensor(
      json['temperature'] as double,
      json['humidity'] as double,
      json['pressure'] as double,
      json['battery'] as int,
      json['linkQuality'] as int,
      json['created'] == null ? null : (json['created'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'temperature': this.temperature,
      'humidity': this.humidity,
      'pressure': this.pressure,
      'battery': this.battery,
      'linkQuality': this.linkQuality,
      'created': this.created,
    };
  }




}