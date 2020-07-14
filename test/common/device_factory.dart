import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/measured_property.dart';

class TestingDevideFactory {
  static Device getAqaraTemperatureSensor() {
    final teplotaProperty = MeasuredProperty('teplota', 'C',
        description: 'teplota', createdAt: DateTime.now());

    final mproperties = <MeasuredProperty>[];
    mproperties.add(teplotaProperty);

    return Device('aqara_teplomer', properties: mproperties);
  }

  static Device getAqaraTemperatureSensorWithId(String id) {
    final teplotaProperty = MeasuredProperty('teplota', 'C',
        description: 'teplota', createdAt: DateTime.now());

    final mproperties = <MeasuredProperty>[];
    mproperties.add(teplotaProperty);

    return Device('aqara_teplomer_$id', properties: mproperties, id: id);
  }

  static List<Device> getListOfAqaraTempSensors(int count){
    return List.generate(count, (i) => TestingDevideFactory.getAqaraTemperatureSensorWithId('$i'));
  }
}
