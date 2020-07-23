import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/iothub.dart';

import 'iot_hub_main_widget.dart';

class IOTHubDashboard extends StatefulWidget {
  final String title;
  final String body;

  IOTHubDashboard(this.title, this.body, {Key key})
      : assert(title != null),
        assert(body?.isNotEmpty ?? false),
        super(key: key);

  @override
  _IOTHubDashboardState createState() => _IOTHubDashboardState(title, body);
}

class _IOTHubDashboardState extends State<IOTHubDashboard> {
  final String title;
  final String body;

  _IOTHubDashboardState(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),
        title: Text(title),
      ),
      // body is the majority of the screen.
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('/iothubs').snapshots(),
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
