import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/routes/iothub_routes.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubList extends StatelessWidget {
  const IOTHubList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IOT Hubs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Close IOT HUb',
          onPressed: () async {
           // await RM.navigate.toNamed(StaticPages.iotHUBApp.routeName);
            await IOTHubsMainPage.user.auth.signOut();
          },
        ),
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return OnFutureBuilder<List<IOTHub>>(
      future: () => IOTHubsMainPage.iotHubService.state.loadAllIOTHubs(),
      onWaiting: () => const CommonDataLoadingIndicator(),
      onError: (error, refresher) => Text(ErrorHandler.getErrorMessage(error)), //Future can be reinvoked
      onData: (data, refresh) => _buildList(context, data),);
  }

  Widget _buildList(BuildContext context, List<IOTHub> iothubList) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: iothubList.map((iotHub) => _buildListItem(context, iotHub)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, IOTHub iotHub) {
    return Padding(
      key: ValueKey(iotHub.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(iotHub.name),
          subtitle: iotHub.gps != null
              ? Text(iotHub.gps!.latitude.toString() + ';' + iotHub.gps!.longitude.toString())
              : const Text(''),
          trailing: Text(iotHub.createdAt.toString()),
          onTap: () {
            RM.navigate.toNamed(IOTHUBStaticPages.dashboard.fullPath, arguments: iotHub);
          },
        ),
      ),
    );
  }
}
