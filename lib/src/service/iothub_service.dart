
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';

class IOTHubService {
  IOTHubService(this._dbRepository);

  final IOTHubRepository _dbRepository;

  List<Device> _devices = const [];
  List<Measurement> _deviceMeasurment = const [];

  //CRUD methods
  void loadAllDevices() async {
    _devices = await _dbRepository.loadAllDevices();
  }

  void loadLastMeasurement(Device device) async {
    _deviceMeasurment = await _dbRepository.loadLastMeasurement(device);
  }
  
}