import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iothub/src/data_source/auth_repository_impl.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/interfaces/auth_repository.dart';
import 'package:iothub/src/service/user_state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'iot_hub_dashboard_widget.dart';

/// Show a and manage IOT hubs
class IOTHubsMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    Widget _createMainWidget(BuildContext context){
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
            child:  Column(
              children: [
                CircularProgressIndicator(),
                Text('Loading user data ...'),
              ],
            ),
          ),
          builder: (context, authStateRM) => authStateRM.state.signedUser.uid !=
              null
              ? IOTHubDashboard('muj title', 'moje body')
              : Text('User was not signing in')
      );
    }

    return Injector(
      inject: [
        //Inject the AuthRepository implementation and register is via its IAuthRepository interface.
        //This is important for testing (see bellow).
        Inject<AuthRepository>(
              () => AuthRepositoryImpl(),
        ),
        Inject<UserState>(
              () => UserState(User(),
              IN.get<AuthRepository>()
          ),
        )
      ],
      builder: _createMainWidget,
    );

  }

}