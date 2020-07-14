import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measurement.dart';

import '../../domain/entities/device.dart';

abstract class IOTHubRepository {
  Future<List<IOTHub>> loadAllIOTHubs();
  Future<List<Device>> loadAllDevices();
  Future<List<Measurement>> loadLastMeasurement(Device device);
}