import 'package:flutter/material.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iot_hub_dashboard_widget.dart';
import '../../service/user_state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WhenRebuilderOr<UserState>(
      key: Key('Current user'),
      watch: (rm) => rm.state.signedUser,
      observe: () => RM.get<UserState>().future((s, stateAsync) {

        if(s.signedUser.uid != null){
          return stateAsync;
        }

        return UserState.currentUser(s).then((user) {
          if(user.signedUser.uid != null){
            return user;
          }
          return UserState.signInWithEmailAndPassword(user, 'karlovjan@gmail.com', 'Flutter753123');
        });
      }),
      dispose: (_, userState) => UserState.signOut(userState.state),
      initState: (context, m) => Text('Getting FB user'),
      onWaiting: () => Center(
        child:  Row(
          children: [
            CircularProgressIndicator(),
            Text('Loading user data ...'),
          ],
        ),
      ),
      builder: (context, authStateRM) => authStateRM.state.signedUser.uid !=
              null
          ? IOTHubDashboard('muj titile', 'moje body')
          : Text('User was not signing in')
    );
  }
}
