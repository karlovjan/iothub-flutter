import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iothub/src/data_source/auth_repository_impl.dart';
import 'package:iothub/src/data_source/cfs_repository.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/interfaces/auth_repository.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/service/user_state.dart';
import 'package:iothub/src/ui/pages/iothubs.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/// Show a and manage IOT hubs
class IOTHubsMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _createMainWidget(BuildContext context) {
      return WhenRebuilderOr<UserState>(
          key: Key('Current user'),
          watch: (rm) => rm.state.signedUser,
          observe: () => RM.get<UserState>().future((s, stateAsync) {
                if (s.signedUser.uid != null) {
                  return stateAsync;
                }

                return UserState.currentUser(s).then((user) {
                  if (user.signedUser.uid != null) {
                    return user;
                  }
                  return UserState.signInWithEmailAndPassword(
                      user, 'karlovjan@gmail.com', 'Flutter753123');
                });
              }),
          dispose: (_, userState) => UserState.signOut(userState.state),
          onWaiting: () => CommonDataLoadingIndicator(),
          builder: (context, authStateRM) =>
              authStateRM.state.signedUser.uid != null
                  ? IOTHubList()
                  : Text('User was not signing in'));
    }

    Widget _createMainWidgetTemplate(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _createMainWidget(context),
        ),
      );
    }

    return Injector(
      inject: [
        //Inject the AuthRepository implementation and register is via its IAuthRepository interface.
        //This is important for testing (see bellow).
        Inject<AuthRepository>(
          () => FirebaseAuthRepository(),
        ),
        Inject<UserState>(
          () => UserState(User(), IN.get<AuthRepository>()),
        ),
        Inject<IOTHubRepository>(
          () => CloudFileStoreDBRepository(),
        ),
        Inject<IOTHubService>(
          () => IOTHubService(IN.get<IOTHubRepository>()),
        ),
      ],
      builder: _createMainWidgetTemplate,
    );
  }
}
