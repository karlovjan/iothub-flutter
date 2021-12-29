import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measured_property.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/exceptions/database_exception.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';
import 'package:logger/logger.dart';

@immutable
class CloudFileStoreDBRepository implements IOTHubRepository {
  final FirebaseFirestore _dbClient = FirebaseFirestore.instance;

  final log = Logger(
    printer: PrettyPrinter(),
  );

  //private getters
  static const String _IOTHUB_ROOT_COLLECTION_PATH = '/iothubs';

  @override
  Future<List<Device>> loadAllDevices(String iotHubId) async {

    try {
      final snapshot = await _dbClient.collection('$_IOTHUB_ROOT_COLLECTION_PATH/$iotHubId/devices').get();

      var deviceList = <Device>[];

      for (var item in snapshot.docs) {
          deviceList.add(Device.fromJson(item.data(), item.id));
        }

      return deviceList;
    } catch (e) {
      throw DatabaseException('There is a problem in loading Devices : $e');
    }
  }

  @override
  Future<List<Measurement>> loadLastMeasurement(String iotHubId, Device device) async {

    try {
      final snapshot = await _dbClient
          .collection('$_IOTHUB_ROOT_COLLECTION_PATH/$iotHubId/devices/${device.id}/data')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      log.i('device data was loaded ${device.name}');

      return _createMeasurementList(snapshot);
    } catch (e) {
      throw DatabaseException('There is a problem in loading last measurement of the Device ${device.name} : $e');
    }
  }

  List<Measurement> _createMeasurementList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final measurementList = <Measurement>[];

    if (snapshot.docs.isEmpty) {
      return measurementList;
    }

    final data = snapshot.docs.first.data();

    //TODO device.properties.forEach((deviceMeasuredProperty) {
    allDeviceMeasuredPropertyList().forEach((deviceMeasuredProperty) {
      if (data[deviceMeasuredProperty.name] != null) {
        measurementList.add(Measurement.fromJson(data, deviceMeasuredProperty));
      }
    });

    return measurementList;
  }

  @override
  Future<List<IOTHub>> loadAllIOTHubs() async {
    try {
      var iothubList = <IOTHub>[];

      final snapshot = await _dbClient.collection(_IOTHUB_ROOT_COLLECTION_PATH).get();

      for (var item in snapshot.docs) {
          iothubList.add(IOTHub.fromJson(item.data(), item.id));
        }

      return iothubList;
    } catch (e) {
      throw DatabaseException('There is a problem in loading IOTHubs : $e');
    }
  }

  @override
  Stream<List<Measurement>> deviceAllMeasurementStream(String iotHubId, Device device) async* {

    try {
      final snapshot = _dbClient
          .collection('$_IOTHUB_ROOT_COLLECTION_PATH/$iotHubId/devices/${device.id}/data')
          .orderBy('createdAt', descending: true)
          .snapshots();

      log.i('snapshot created for device ${device.name}');

      var streamWithoutErrors = snapshot.handleError(_printError);

      await for (var deviceMeasurement in streamWithoutErrors) {
        yield _createMeasurementList(deviceMeasurement);
      }
    } catch (e) {
      throw DatabaseException('There is a problem in the device measurement stream : $e');
    }
  }

  List<MeasuredProperty> allDeviceMeasuredPropertyList() {
    const mp1 = MeasuredProperty('temperature', 'C');
    const mp2 = MeasuredProperty('humidity', 'X');
    const mp3 = MeasuredProperty('pressure', 'Pa');
    const mp4 = MeasuredProperty('battery', '%');
    const mp5 = MeasuredProperty('linkquality', '%');
    const mp6 = MeasuredProperty('contact', 'Boolean');
    const mp7 = MeasuredProperty('occupancy', 'Boolean');
    const mp8 = MeasuredProperty('leak', 'Boolean');

    return [mp1, mp2, mp3, mp4, mp5, mp6, mp7, mp8];
  }

  @override
  Stream<Measurement> deviceFilteredMeasurementStream(
      String iotHubId, String deviceId, Measurement<dynamic> watchedDeviceMeasurement) {
    // TODO: implement deviceFilteredMeasurementStream
    throw UnimplementedError();
  }

  void _printError(Error e) {
    log.e('Stream measurement error', e);
  }
}
