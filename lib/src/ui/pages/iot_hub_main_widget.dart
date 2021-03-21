import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iothub/src/data_source/auth_repository_impl.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/user_state.dart';
import 'package:iothub/src/service/interfaces/auth_repository.dart';
import 'package:iothub/src/ui/pages/iothub/dashboard.dart';
import 'package:iothub/src/ui/pages/iothub/devices.dart';
import 'package:iothub/src/ui/pages/nas/nas_sync_page.dart';
import 'package:iothub/src/ui/routes/iothub_routes.dart';
import 'package:iothub/src/ui/routes/main_routes.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'home.dart';
import 'iot_hubs.dart';

class IOTHubMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //uncomment this line to consol log and see the notification timeline
    RM.debugPrintActiveRM = true;

    return MaterialApp(
      title: 'IOT hub',
      theme: ThemeData.dark(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        // visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
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



  }

}

