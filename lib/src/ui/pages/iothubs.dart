import 'package:flutter/material.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/service/user_state.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class IOTHubList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),
        title: Text('IOT Hubs'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Close IOT HUb',
            onPressed: () => {
              UserState.signOut(RM.get<UserState>().state).then((value) => Navigator.pop(context))
            }),
        ],
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );

  }

  Widget _buildBody(BuildContext context) {

    return WhenRebuilderOr<IOTHubService>(
        key: Key('IOT HUb list screen'),
        observe: () => RM.get<IOTHubService>().setState((s) => {
          if(s.isIOTHubCollectionEmpty) {
            s.loadAllIOTHubs();
    }
          return;
        }),
        watch: (rm) => rm.state.iothubs,
        onWaiting: () => CommonDataLoadingIndicator(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong. ${snapshot.error.toString()}');
          }

          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }

          return _buildList(context, snapshot.data.documents);
        });
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = IOTHub.fromJson(data.data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          subtitle: Text(record.gps.latitude.toString() +
              ';' +
              record.gps.longitude.toString()),
          trailing: Text(record.createdAt.toString()),
        ),
      ),
    );
  }

}