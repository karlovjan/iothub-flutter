import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/service/iothub_dashboard_state.dart';

void main() {
  group('dashboard state ', () {
    test('add new device', () {
      final dashboard = DashboardState();

      // dashboard.addEntity(GaugeChart.withSampleData());
      // dashboard.addEntity(GaugeChart.withSampleData());
      // dashboard.addEntity(GaugeChart.withSampleData());

      expect(dashboard.entities.length, 0);
    });
  });
}
