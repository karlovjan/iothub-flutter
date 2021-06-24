import 'package:flutter/material.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/widgets/splash_screen.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'src/ui/pages/iothub/dashboard.dart';
import 'src/ui/pages/iothub/devices.dart';
import 'src/ui/pages/nas/nas_sync_page.dart';
import 'src/ui/routes/iothub_routes.dart';
import 'src/ui/routes/main_routes.dart';

void main() async {
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight();
  runApp(IOTHubApp());
}

class IOTHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //uncomment this line to consol log and see the notification timeline
    // RM.debugPrintActiveRM = true;

    return TopAppWidget(
      onWaiting: () => MaterialApp(
        home: const SplashScreen(),
      ),
      builder: (_) => MaterialApp(
        title: 'IOT hub',
        theme: ThemeData.dark(),
        onGenerateRoute: RM.navigate.onGenerateRoute({
          StaticPages.home.routeName: (_) => const HomePage(),
          StaticPages.hubs.routeName: (_) => RouteWidget(
            builder: (_) => const IOTHubsMainPage(),
            routes: {
              IOTHUBStaticPages.devices.routeName: (data) => IOTHubDeviceListPage(data.arguments as IOTHub),
              IOTHUBStaticPages.dashboard.routeName: (data) => IOTHubDashboardPage(data.arguments as IOTHub),
            },
          ),
          StaticPages.nasSync.routeName: (context) => const NASSyncMainPage(),
        }),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );

    /*
    return MaterialApp(
      title: 'IOT hub',
      theme: ThemeData.dark(),
      // To navigate and show snackBars without the BuildContext, we define
      // the navigator key
      navigatorKey: RM.navigate.navigatorKey,
      initialRoute: StaticPages.home.routeName,
      routes: {
        StaticPages.home.routeName: (context) => const HomePage(),
        StaticPages.hubs.routeName: (context) => IOTHubsMainPage(),
        StaticPages.nasSync.routeName: (context) => const NASSyncMainPage(),
        IOTHUBStaticPages.devices.routeName: (context) => IOTHubDeviceListPage(),
        IOTHUBStaticPages.dashboard.routeName: (context) => IOTHubDashboardPage(),
      },
//      home: HomeWidget(),
//      home: IOTHubDashboard('Praha dashboard', 'Moje grafy'),
//      home: GaugeChart.withSampleData(),
    );

     */
  }
}
