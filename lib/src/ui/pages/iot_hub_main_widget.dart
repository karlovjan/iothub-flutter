import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'iot_hub_dashboard_widget.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

void signOut() async {
  await auth.signOut();
}

void signInWithEmailAndPassword() async {
  final user = await auth.signInWithEmailAndPassword(
    email: 'mironb@seznam.cz',
    password: 'Flutter753123',
  );

  if(user != null) {
    print(user.user.uid);
  }

}

class IOTHubMainWidget extends StatelessWidget {

  IOTHubMainWidget(){
   signInWithEmailAndPassword();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT hub',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: IOTHubDashboard('Praha dashboard', 'Moje grafy'),
//      home: GaugeChart.withSampleData(),

    );
  }

}
