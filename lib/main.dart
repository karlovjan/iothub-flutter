import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/ui/pages/bluetooth/bluetooth_app.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/pages/preferences/global_preferences_page.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'src/global_objects.dart';
import 'src/ui/pages/iothub/dashboard.dart';
import 'src/ui/pages/iothub/devices.dart';
import 'src/ui/pages/iothub/iothubs.dart';
import 'src/ui/pages/nas/nas_sync_page.dart';
import 'src/ui/routes/iothub_routes.dart';
import 'src/ui/routes/main_routes.dart';

void main() async {
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight();
  runApp(const IOTHubApp());
}

class IOTHubApp extends TopStatelessWidget {
  const IOTHubApp({Key? key}) : super(key: key);

  @override
  List<Future> ensureInitialization() => [
        //Plugins can be initialized, to display our Splash screen
        RM.storageInitializer(preferences),
      ];

  @override
  Widget? splashScreen() => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    //uncomment this line to consol log and see the notification timeline
    // RM.debugPrintActiveRM = true;

    return MaterialApp(
      title: 'IOT hub',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,
      navigatorKey: RM.navigate.navigatorKey,
      onGenerateRoute: RM.navigate.onGenerateRoute(
        {
          StaticPages.home.routeName: (_) => const HomePage(),
          StaticPages.iotHUBApp.routeName: (_) => RouteWidget(
                routes: {
                  StaticPages.home.routeName: (data) => const IOTHubsMainPage(),
                  IOTHUBStaticPages.hubs.routeName: (data) =>
                      const IOTHubList(),
                  IOTHUBStaticPages.devices.routeName: (data) =>
                      IOTHubDeviceListPage(data.arguments as IOTHub?),
                  IOTHUBStaticPages.dashboard.routeName: (data) =>
                      IOTHubDashboardPage(data.arguments as IOTHub?),
                },
              ),
          StaticPages.nasSync.routeName: (context) => const NASSyncMainPage(),
          StaticPages.bluetoothApp.routeName: (context) => const BluetoothApp(),
        },
        unknownRoute: (routeName) => Text('404 - Unknown route $routeName'),
      ),
    );
  }
}
