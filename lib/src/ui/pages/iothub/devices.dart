import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/routes/iothub_routes.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubDeviceListPage extends StatelessWidget {
  final IOTHub _selectedIOTHub;

  const IOTHubDeviceListPage(this._selectedIOTHub);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIOTHub.name),
      ),
      // body is the majority of the screen.
      body: On.future<List<Device>>(
        onWaiting: () => CommonDataLoadingIndicator(),
        onError: (error, refresher) => Text(ErrorHandler.getErrorMessage(error)), //Future can be reinvoked
        onData: (data, refresh) => _buildList(context, data),
      ).future(() => IOTHubsMainPage.iotHubService.state.loadAllDevices(_selectedIOTHub.id)),
    );
  }

  Widget _buildList(BuildContext context, List<Device> devices) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: devices.map((device) => _buildListItem(context, device)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, Device device) {
    return Padding(
      key: ValueKey(device.name),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(device.name),
          subtitle: Text(device.description + ' - ' + device.vendor),
          trailing: Text(device.created.toString()),
          onTap: () {
            RM.navigate.toNamed(IOTHUBStaticPages.devices.routeName);
          },
        ),
      ),
    );
  }
}
