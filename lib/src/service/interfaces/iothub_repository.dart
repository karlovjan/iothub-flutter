import '../../domain/entities/device.dart';
import '../../domain/entities/iothub.dart';
import '../../domain/entities/measurement.dart';

abstract class IOTHubRepository {
  Future<List<IOTHub>> loadAllIOTHubs();

  Future<List<Device>> loadAllDevices(String iotHubId);

  Future<List<Measurement>> loadLastMeasurement(String? iotHubId, Device device);

  Stream<List<Measurement>> deviceAllMeasurementStream(String iothubDocumentId, Device device);

  Stream<Measurement> deviceFilteredMeasurementStream(
      String iotHubId, String deviceId, Measurement watchedDeviceMeasurement);
}
