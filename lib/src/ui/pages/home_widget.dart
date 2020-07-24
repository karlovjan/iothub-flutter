import 'package:flutter/material.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iot_hub_dashboard_widget.dart';
import '../../service/user_state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder<UserState>(
      key: Key('Current user'),
      watch: (rm) => rm.state.signedUser,
      observe: () => RM.get<UserState>()
        ..setState(
          (authState) => UserState.signInWithEmailAndPassword(
              authState, 'karlovjan@gmail.com', 'Flutter753123'),
          onError: ErrorHandler.showErrorDialog,
        ),
      disposeModels: true,
      builder: (context, authStateRM) => authStateRM.state.signedUser.uid !=
              null
          ? IOTHubDashboard('muj titile', 'moje body')
          : Center(
              child: Text('Hello, world!', textDirection: TextDirection.ltr),
            ),
    );
  }
}
