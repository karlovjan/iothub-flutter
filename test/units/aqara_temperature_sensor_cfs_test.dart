import 'package:flutter_test/flutter_test.dart';

import '../common/device_factory.dart';

//class MockitoCFSClient extends Mock implements Firestore {}

void main() {
  group('read temperature sensor data', () {
    test('read all devices', () async {
//      final client = MockitoCFSClient();
//      final repository = CloudFileStoreDBRepository(client);

//      final teplomer = TestingDevideFactory.getAqaraTemperatureSensor();

      final devices = TestingDeviceFactory.getListOfAqaraTempSensors(2);

      final teplomer1 = {'id': '1', 'name': 'aqara_teplomer_1', 'type': '/deviceTypes/sensor'};

      final teplomer2 = {'id': '2', 'name': 'aqara_teplomer_2', 'type': '/deviceTypes/sensor'};

      //result is List<Map<String, dynamic>>
//      when(client.collection('iothubs/1/devices')).thenAnswer((_) => collRef);
//
//      var dbResult = repository.loadAllDevices();
//
//      expect(dbResult, isNull);
    });
  });
}
