
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/exceptions/database_exception.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';


@immutable
class CloudFileStoreDBRepository implements IOTHubRepository {


  CloudFileStoreDBRepository(this._iothubId, [Firestore newFSDBClient]) : _dbClient = newFSDBClient ?? Firestore.instance;

  //final private members
  final String _iothubId;
  final Firestore _dbClient;

  //private getters
  String get _iothubCollectionPath => '/iothubs';
  String get _deviceCollectionPath => '$_iothubCollectionPath/$_iothubId/devices';

  @override
  Future<List<Device>> loadAllDevices() async {
    try {
      final snapshot =
          await _dbClient.collection(_deviceCollectionPath).getDocuments();

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
          await _dbClient.collection(_iothubCollectionPath).getDocuments();

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