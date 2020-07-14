import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/sqlite_db_repository.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/measured_property.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

import '../common/device_factory.dart';

class MockitoSqliteClient extends Mock implements sqlite.Database {}
//class MockitoDBRepository extends Mock implements DBRepository {}

void main() {
  group('read temperature sensor data', () {
    test('read last temperature from sensor', () async {
      final client = MockitoSqliteClient();
//      final dbRepo = MockitoDBRepository();
      final dbRepo = SqliteDBRepository(client);


      final teplomer = TestingDevideFactory.getAqaraTemperatureSensor();


      //result is List<Map<String, dynamic>>
      when(client.query('table')).thenAnswer(
          (_) async => List.generate(2, (i) => <String, dynamic>{'$i': i}));

//      when().thenAnswer((_) => 24.3);

//      service.loadLastMeasurement(teplomer);

//      expect(service.measurement.where((element) => element.property.name == teplotaProperty.name), 24.3);
    });
  });
}
