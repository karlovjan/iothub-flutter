import 'package:flutter/material.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iot_hub_dashboard_widget.dart';
import 'package:iothub/src/ui/routes/main_routes.dart';
import '../../service/user_state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),
        title: Text('Home page'),
      ),
      // body is the majority of the screen.
      body: Column(
        children: [
          FlatButton(onPressed: () {
            Navigator.pushNamed(context, StaticPages.hubs.routeName);
          },
            child: Text('IOT hub'),
          )
        ],
      ),
    );
  }
}
