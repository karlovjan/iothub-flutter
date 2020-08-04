import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubDeviceListPage extends StatelessWidget {

  final service = RM.get<IOTHubService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.state.selectedIOTHub?.name),
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );

  }


  Widget _buildBody(BuildContext context) {
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
          return _buildList(context, modelRM.state.devices);
        });
  }

  Widget _buildList(BuildContext context, List<Device> devices) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children:
      devices.map((device) => _buildListItem(context, device)).toList(),
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
          subtitle: Text(device.description +
              ' - ' +
              device.vendor),
          trailing: Text(device.created.toString()),
        ),
      ),
    );
  }

}
