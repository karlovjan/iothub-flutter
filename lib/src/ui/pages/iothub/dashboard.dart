import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/pages/iothub/manager.dart';
import 'package:iothub/src/ui/widgets/dashboard_device_card.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../global_objects.dart';

class IOTHubDashboardPage extends StatelessWidget {
  final IOTHub? _selectedIOTHub;

  const IOTHubDashboardPage(
    this._selectedIOTHub, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${_selectedIOTHub!.name}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Manage Dashboard',
            onPressed: () {
              RM.navigate.to(const DashboardManagerPage());
            },
          ),
        ],
      ),
      // body is the majority of the screen.
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    if (_selectedIOTHub == null) {
      return const Text('No IotHub selected!');
    }
    return getFutureBuilder<List<Device>>(
      initialData: List.empty(),
      creator: () => IOTHubsMainPage.iotHubService.state
          .loadAllDevices(_selectedIOTHub.id),
      onWaiting: () => const CommonDataLoadingIndicator(),
      onError: (error, refresher) => Text(ErrorHandler.getErrorMessage(error)),
      //Future can be reinvoked
      builder: (rmData) => DashboardDeviceCard(_selectedIOTHub, rmData.state),
    );
  }
}
