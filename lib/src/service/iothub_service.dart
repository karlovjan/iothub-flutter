
import '../domain/entities/device.dart';
import '../domain/entities/iothub.dart';
import '../domain/entities/measurement.dart';
import '../service/interfaces/iothub_repository.dart';

//@immutable
class IOTHubService {
  IOTHubService(this._dbRepository);

  final IOTHubRepository _dbRepository;

  //CRUD methods
  Future<List<IOTHub>> loadAllIOTHubs() async {
    return await _dbRepository.loadAllIOTHubs();
  }

  Future<List<Device>> loadAllDevices(String selectedIOTHubID) async {
    return await _dbRepository.loadAllDevices(selectedIOTHubID);
  }

  Future<List<Measurement>> loadLastMeasurement(
      String iothubId, Device device) async {
    return await _dbRepository.loadLastMeasurement(iothubId, device);
  }

  Stream<List<Measurement>> deviceAllMeasurementStream(
      String iothubDocumentId, Device device) {
    return _dbRepository.deviceAllMeasurementStream(iothubDocumentId, device);
  }
}
