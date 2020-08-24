
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/exceptions/database_exception.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';


@immutable
class CloudFileStoreDBRepository implements IOTHubRepository {

  final Firestore _dbClient = Firestore.instance;

  //private getters
  static final String _IOTHUB_ROOT_COLLECTION_PATH = '/iothubs';

  @override
  Future<List<Device>> loadAllDevices(String iothubDocumentId) async {
    assert(iothubDocumentId != null);

    try {
      final snapshot =
          await _dbClient.collection('$_IOTHUB_ROOT_COLLECTION_PATH/$iothubDocumentId/devices').getDocuments();

      var deviceList = <Device>[];

      snapshot.documents.forEach(
            (item) {
              deviceList.add(Device.fromJson(item.data, item.documentID));
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
      final snapshot =
          await _dbClient.collection(_IOTHUB_ROOT_COLLECTION_PATH).getDocuments();

      var iothubList = <IOTHub>[];

      snapshot.documents.forEach(
            (item) {
          iothubList.add(IOTHub.fromJson(item.data, item.documentID));
        },
      );

      return iothubList;
    } catch (e) {
      throw DatabaseException('There is a problem in loading IOTHubs : $e');
    }
  }

  @override
  Stream<List<Measurement>> deviceAllMeasurementStream(String iothubDocumentId, Device device) async* {
    assert(device != null);
    assert(iothubDocumentId != null);
    assert(device.id != null);
    assert(device.properties != null);

    try {
      final snapshot =
          await _dbClient.collection('$_IOTHUB_ROOT_COLLECTION_PATH/$iothubDocumentId/devices/${device.id}/data').orderBy('createdAt', descending: true).limit(1).snapshots();

      final measurementList = <Measurement>[];

      await for (var deviceMeasurement in snapshot) {
//        deviceMeasurement.documents.forEach((document) {

      final data = deviceMeasurement.documents.first.data;

          device.properties.forEach((deviceMeasuredProperty) {
            measurementList.add( Measurement.fromJson(data, deviceMeasuredProperty));
          });

        };

        yield measurementList;


//      yield measurementList;
    } catch (e) {
      throw DatabaseException('There is a problem in Device measurement stream : $e');
    }
  }

  @override
  Stream<Measurement> deviceFilteredMeasurementStream(String iothubDocumentId, String deviceId, Measurement<dynamic> watchedDeviceMeasurement) {
    // TODO: implement deviceFilteredMeasurementStream
    throw UnimplementedError();
  }

}