import 'package:flutter/material.dart';
import 'package:iothub/src/ui/pages/preferences/global_preferences_page.dart';
import 'package:iothub/src/ui/routes/main_routes.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
        actions: [IconButton(
          icon: const Icon(Icons.build),
          tooltip: 'Preferences',
          onPressed: () {
            RM.navigate.to(const GlobalPreferencesPage());
          },
        ),
        ],
      ),
      // body is the majority of the screen.
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(4),
        children: [
          TileNavigationButton(
              routeName: StaticPages.iotHUBApp.routeName, title: 'IOT Hub'),
          TileNavigationButton(
              routeName: StaticPages.nasSync.routeName, title: 'NAS Sync'),
          TileNavigationButton(
              routeName: StaticPages.bluetoothApp.routeName, title: 'Bluetooth'),
        ],
      ),
    );
  }
}
