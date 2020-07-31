
import 'package:flutter/foundation.dart';

import '../domain/entities/device.dart';
import '../domain/entities/iothub.dart';
import '../domain/entities/measurement.dart';
import '../service/interfaces/iothub_repository.dart';

//@immutable
class IOTHubService {
  IOTHubService(this._dbRepository);

  final IOTHubRepository _dbRepository;

  List<IOTHub> _iothubs;

  IOTHub _selectedIOTHub;

  List<IOTHub> get iothubs => _iothubs ?? const [];
  bool get isIOTHubCollectionEmpty => iothubs.isEmpty;

  //CRUD methods
  Future<List<IOTHub>> loadAllIOTHubs() async {
//    if(!isIOTHubCollectionEmpty){
//      return iothubs;
//    }
    _iothubs = await _dbRepository.loadAllIOTHubs();

    return iothubs;
  }

  void loadAllDevices(String iothubDocumentId) async {
//    _devices = await _dbRepository.loadAllDevices(iothubDocumentId);
  }

  void loadLastMeasurement(Device device) async {
//    _deviceMeasurment = await _dbRepository.loadLastMeasurement(device);
  }
  
}