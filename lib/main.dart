import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'src/ui/pages/iothub/dashboard.dart';
import 'src/ui/pages/iothub/devices.dart';
import 'src/ui/pages/iothub/iothubs.dart';
import 'src/ui/pages/nas/nas_sync_page.dart';
import 'src/ui/routes/iothub_routes.dart';
import 'src/ui/routes/main_routes.dart';

void main() {
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight();
  runApp(IOTHubApp());
}

class IOTHubApp extends TopStatelessWidget {
  @override
  Widget build(BuildContext context) {
    //uncomment this line to consol log and see the notification timeline
    // RM.debugPrintActiveRM = true;

    return MaterialApp(
      title: 'IOT hub',
      theme: ThemeData.dark(),
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
        },
        unknownRoute: (routeName) => Text('404 - Unknown route $routeName'),
      ),
    );
  }
}
