import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
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
  static final String _IOTHUB_ROOT_COLLECTION_PATH = '/iothubs';

  @override
  Future<List<Device>> loadAllDevices(String iothubDocumentId) async {
    assert(iothubDocumentId != null);

    try {
      final snapshot = await _dbClient
          .collection('$_IOTHUB_ROOT_COLLECTION_PATH/$iothubDocumentId/devices')
          .get();

      var deviceList = <Device>[];

      snapshot.docs.forEach(
        (item) {
          deviceList.add(Device.fromJson(item.data(), item.id));
        },
      );

      return deviceList;
    } catch (e) {
      throw DatabaseException('There is a problem in loading Devices : $e');
    }
  }

  @override
  Future<List<Measurement>> loadLastMeasurement(Device device) {
    // TODO: implement loadLastMeasurement
    throw UnimplementedError();
  }

  @override
  Future<List<IOTHub>> loadAllIOTHubs() async {
    try {
      var iothubList = <IOTHub>[];

      final snapshot =
          await _dbClient.collection(_IOTHUB_ROOT_COLLECTION_PATH).get();

      snapshot.docs.forEach(
        (item) {
          iothubList.add(IOTHub.fromJson(item.data(), item.id));
        },
      );

      return iothubList;
    } catch (e) {
      throw DatabaseException('There is a problem in loading IOTHubs : $e');
    }
  }

  @override
  Stream<List<Measurement>> deviceAllMeasurementStream(
      String iothubDocumentId, Device device) async* {
    assert(device != null);
    assert(iothubDocumentId != null);
    assert(device.id != null);
    assert(device.properties != null);

    try {
      final snapshot = await _dbClient
          .collection(
              '$_IOTHUB_ROOT_COLLECTION_PATH/$iothubDocumentId/devices/${device.id}/data')
          .orderBy('createdAt', descending: true)
          .snapshots();

      log.i('snapshot created..');

      var streamWithoutErrors = snapshot.handleError(_printError);

      await for (var deviceMeasurement in streamWithoutErrors) {
//        deviceMeasurement.documents.forEach((document) {

        final data = deviceMeasurement.docs.first.data();
        final measurementList = <Measurement>[];

        device.properties.forEach((deviceMeasuredProperty) {
          measurementList
              .add(Measurement.fromJson(data, deviceMeasuredProperty));
        });

        yield measurementList;
      }
    } catch (e) {
      throw DatabaseException(
          'There is a problem in the device measurement stream : $e');
    }
  }

  @override
  Stream<Measurement> deviceFilteredMeasurementStream(String iothubDocumentId,
      String deviceId, Measurement<dynamic> watchedDeviceMeasurement) {
    // TODO: implement deviceFilteredMeasurementStream
    throw UnimplementedError();
  }

  void _printError(Error e) {
    log.e('Stream measurement error', e);
  }
}
