import 'package:flutter/material.dart';
import 'package:iothub/src/ui/routes/main_routes.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page'),
      ),
      // body is the majority of the screen.
      body: Column(
        children: [
          FlatButton(
            onPressed: () {
              Navigator.pushNamed(context, StaticPages.hubs.routeName);
            },
            child: Text('IOT hub'),
          )
        ],
      ),
    );
  }
}
