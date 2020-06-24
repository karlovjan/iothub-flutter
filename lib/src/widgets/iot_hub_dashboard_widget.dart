import 'package:flutter/material.dart';

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
      body: Center(
        child: Text('Moje body: $body'),
      ),
    );
  }
}
