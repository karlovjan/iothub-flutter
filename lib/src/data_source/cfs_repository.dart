
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
              deviceList.add(Device.fromJson(item.data));
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
          iothubList.add(IOTHub.fromJson(item.data));
        },
      );

      return iothubList;
    } catch (e) {
      throw DatabaseException('There is a problem in loading IOTHubs : $e');
    }
  }

}