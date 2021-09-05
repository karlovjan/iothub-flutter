import 'package:flutter/material.dart';
import 'package:iothub/src/ui/routes/main_routes.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page'),
      ),
      // body is the majority of the screen.
      body: GridView.extent(
        maxCrossAxisExtent: 120.0,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
        children: [
          TileNavigationButton(routeName: StaticPages.iotHUBApp.routeName, title: 'IOT Hub'),
          TileNavigationButton(routeName: StaticPages.nasSync.routeName, title: 'NAS Sync'),
        ],
      ),
    );
  }
}