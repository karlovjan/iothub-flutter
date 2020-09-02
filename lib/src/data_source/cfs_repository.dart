import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/exceptions/database_exception.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';
import 'package:logger/logger.dart';

@immutable
class CloudFileStoreDBRepository implements IOTHubRepository {
  final Firestore _dbClient = Firestore.instance;

  var log = Logger(
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
          .getDocuments();

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

      /*
      Kod pro opravu datumu v karlovicich, pak se smaze
      final testDocs = await _dbClient
          .collection(
          '$_IOTHUB_ROOT_COLLECTION_PATH/1/devices/1/data')
          .orderBy('createdAt', descending: true).getDocuments();

      testDocs.documents.forEach(
            (item) async {
              if (!(item.data['createdAt'] is Timestamp)) {
                final sDateTime = item.data['createdAt'] as String;
                await item.reference.updateData({'createdAt': Timestamp.fromDate(DateFormat('EEE MMM d yyyy HH:mm:ss').parse(sDateTime))}).then((value) => log.i('updated OK'), onError: (Error e) =>_printError(e));
              }

        },
      );

       */

      final snapshot = await _dbClient
          .collection(_IOTHUB_ROOT_COLLECTION_PATH)
          .getDocuments();

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

        final data = deviceMeasurement.documents.first.data;
        final measurementList = <Measurement>[];

        device.properties.forEach((deviceMeasuredProperty) {
          measurementList
              .add(Measurement.fromJson(data, deviceMeasuredProperty));
        });

        yield measurementList;
      }
    } catch (e) {
      throw DatabaseException(
          'There is a problem in Device measurement stream : $e');
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
