import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDBRepository implements IOTHubRepository {
  SqliteDBRepository(Database client);

//  final database = openDatabase(
  // Set the path to the database. Note: Using the `join` function from the
  // `path` package is best practice to ensure the path is correctly
  // constructed for each platform.
//    join(await getDatabasesPath(), 'doggie_database.db'),
  // When the database is first created, create a table to store dogs.
//      onCreate: (db, version) {
//  return db.execute(
//  "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
//  );
//  },
  // Set the version. This executes the onCreate function and provides a
  // path to perform database upgrades and downgrades.
//  version: 1,
//  );

  @override
  Future<List<Device>> loadAllDevices() {
    // TODO: implement loadAllSensors
    throw UnimplementedError();
  }

  @override
  Future<List<Measurement>> loadLastMeasurement(Device device) {
    // TODO: implement loadLastMeasurement
    throw UnimplementedError();
  }

  @override
  Future<List<IOTHub>> loadAllIOTHubs() {
    // TODO: implement loadAllIOTHubs
    throw UnimplementedError();
  }
}
