import 'package:flutter/material.dart';

class IOTHubDashboard extends StatefulWidget {
  final String title;

  IOTHubDashboard({Key key, this.title}) : super(key: key);

  @override
  _IOTHubDashboardState createState() => _IOTHubDashboardState();

}

class _IOTHubDashboardState extends State<IOTHubDashboard> {
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
        title: Text('IOT Hub title'),

      ),
      // body is the majority of the screen.
      body: Center(
        child: Text('Hurraa!'),
      ),

    );
  }
}