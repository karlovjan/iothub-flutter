import 'package:flutter/material.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/dashboard/manager.dart';
import 'package:iothub/src/ui/widgets/dashboard_device_card.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubDashboardPage extends StatelessWidget {
  final service = RM.get<IOTHubService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ' + service.state.selectedIOTHub?.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Manage Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<DashboardManagerPage>(
                    builder: (context) => DashboardManagerPage()),
              );
            },
          ),
        ],
      ),
      // body is the majority of the screen.
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
//    return GaugeChart.withSampleData();
    return WhenRebuilderOr<IOTHubService>(
        key: Key('IOT HUb device list screen'),
        observe: () => service
          ..setState(
            (s) => s.loadAllDevices(),
            onError: ErrorHandler.showErrorSnackBar,
          ),
        watch: (rm) => rm.state.devices,
        onWaiting: () => CommonDataLoadingIndicator(),
        builder: (context, modelRM) {
          return DashboardDeviceCard(
              devices: modelRM.state.devices, iotHubService: service);
        });
    /*
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DashboardDeviceCard(devices: null, iotHubService: service),
      ],
    );

     */
  }
}
