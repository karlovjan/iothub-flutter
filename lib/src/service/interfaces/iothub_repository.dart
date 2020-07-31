import '../../domain/entities/iothub.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/entities/device.dart';

abstract class IOTHubRepository {
  Future<List<IOTHub>> loadAllIOTHubs();

  Future<List<Device>> loadAllDevices(String iothubDocumentId);

  Future<List<Measurement>> loadLastMeasurement(Device device);
}
