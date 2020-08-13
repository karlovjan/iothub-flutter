import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/service/user_state.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/routes/iothub_routes.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IOT Hubs'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Close IOT HUb',
            onPressed: () => {
              UserState.signOut(RM.get<UserState>().state)
                  .then((value) => Navigator.pop(context))
            }),
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return WhenRebuilderOr<IOTHubService>(
        key: Key('IOT HUb list screen'),
        observe: () => RM.get<IOTHubService>()
          ..setState(
            (s) => s.loadAllIOTHubs(),
            onError: ErrorHandler.showErrorSnackBar,
          ),
        watch: (rm) => rm.state.iothubs,
        onWaiting: () => CommonDataLoadingIndicator(),
        builder: (context, modelRM) {
          return _buildList(context, modelRM.state.iothubs);
        });
  }

  Widget _buildList(BuildContext context, List<IOTHub> iothubList) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children:
          iothubList.map((iotHub) => _buildListItem(context, iotHub)).toList(),
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
          subtitle: Text(iotHub.gps.latitude.toString() +
              ';' +
              iotHub.gps.longitude.toString()),
          trailing: Text(iotHub.createdAt.toString()),
          onTap: () {
            RM.get<IOTHubService>().state.selectedIOTHub = iotHub;
            Navigator.pushNamed(context, IOTHUBStaticPages.dashboard.routeName);
          },
        ),
      ),
    );
  }
}
