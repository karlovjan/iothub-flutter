import 'package:iothub/src/service/exceptions/database_exception.dart';

import '../domain/entities/device.dart';
import '../domain/entities/iothub.dart';
import '../domain/entities/measurement.dart';
import '../service/interfaces/iothub_repository.dart';

//@immutable
class IOTHubService {
  IOTHubService(this._dbRepository);

  final IOTHubRepository _dbRepository;

  List<IOTHub> _iothubs;
  List<Device> _devices;

  IOTHub selectedIOTHub;
  Device selectedDevice;

  List<IOTHub> get iothubs => _iothubs ?? const [];

  List<Device> get devices => _devices ?? const [];

  bool get isIOTHubCollectionEmpty => iothubs.isEmpty;

  //CRUD methods
  Future<void> loadAllIOTHubs() async {
    _iothubs = await _dbRepository.loadAllIOTHubs();
  }

  Future<void> loadAllDevices() async {
    if (selectedIOTHub == null ||
        selectedIOTHub.id == null ||
        selectedIOTHub.id.isEmpty) {
      throw DatabaseException('NO IOT HUb selected');
    }
    _devices = await _dbRepository.loadAllDevices(selectedIOTHub.id);
  }

  void loadLastMeasurement(Device device) async {
//    _deviceMeasurment = await _dbRepository.loadLastMeasurement(device);
  }

  Stream<List<Measurement>> deviceAllMeasurementStream(
      String iothubDocumentId, Device device) {
    return _dbRepository.deviceAllMeasurementStream(iothubDocumentId, device);
  }
}
