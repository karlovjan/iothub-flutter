import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/cfs_repository.dart';
import 'package:iothub/src/data_source/sqlite_db_repository.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/measured_property.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

import '../common/device_factory.dart';

//class MockitoCFSClient extends Mock implements Firestore {}


void main() {
  group('read temperature sensor data', () {

    test('read all devices', () async {

//      final client = MockitoCFSClient();
//      final repository = CloudFileStoreDBRepository(client);

//      final teplomer = TestingDevideFactory.getAqaraTemperatureSensor();

      final devices = TestingDevideFactory.getListOfAqaraTempSensors(2);


      final teplomer1 = {
        'name': 'aqara_teplomer_1',
        'type': '/deviceTypes/sensor'
      };

      final teplomer2 = {
        'name': 'aqara_teplomer_2',
        'type': '/deviceTypes/sensor'
      };


      //result is List<Map<String, dynamic>>
//      when(client.collection('iothubs/1/devices')).thenAnswer((_) => collRef);
//
//      var dbResult = repository.loadAllDevices();
//
//      expect(dbResult, isNull);
    });


  });
}