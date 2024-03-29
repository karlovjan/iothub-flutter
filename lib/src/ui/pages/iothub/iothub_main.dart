import 'package:flutter/material.dart';
import 'package:iothub/src/data_source/auth_repository.dart';
import 'package:iothub/src/data_source/cfs_repository.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/exceptions/error_handler.dart';
import 'package:iothub/src/ui/pages/iothub/iothubs.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../home_page/home_page.dart';

/// Show a and manage IOT hubs
class IOTHubsMainPage extends StatelessWidget {
  static final InjectedAuth<User, UserParam> user =
      RM.injectAuth<User, UserParam>(
    () => FirebaseAuthRepository(),
    unsignedUser: const LoggedOutUser(),
    onAuthStream: (repo) =>
        (repo as FirebaseAuthRepository).currentUser().asStream(),
    sideEffects: SideEffects.onError(
      (err, refresh) => ErrorHandler.showErrorDialog(err),
    ),
  );

  static final iotHubService = RM.inject<IOTHubService>(
    () => IOTHubService(CloudFileStoreDBRepository()),
  );

  const IOTHubsMainPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IOT Hub main page'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Close IOT HUb',
            onPressed: () async {
              await user.auth.signOut();
              // await RM.navigate.backAndToNamed(StaticPages.home.routeName);
            }),
      ),
      // body is the majority of the screen.
      body: getAuthWidget(),
    );
  }

  Widget getAuthWidget() {
    return OnAuthBuilder(
      listenTo: user,
      onInitialWaiting: () {
        user.auth.signIn((param) => UserParam(
            email: 'karlovjan@gmail.com',
            password: 'Flutter753123',
            signIn: SignIn.withEmailAndPassword));

        return const LoggingIndicator();
      },
      onWaiting: () => const LoggingIndicator(),
      onUnsigned: () => const HomePage(),
      onSigned: () => const IOTHubList(),
      useRouteNavigation: true,
    );
  }
}
