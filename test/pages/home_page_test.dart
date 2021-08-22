import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
import 'package:iothub/src/data_source/auth_repository.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/pages/iothub/iothubs.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_page_test.mocks.dart';

class FakeAuthRepository implements FirebaseAuthRepository {
  Error? exception;

  FakeAuthRepository();

  bool _logouted = true;

  final User _user = User(
    uid: '1',
    displayName: 'FakeUser',
    email: 'fake@email.com',
  );

  @override
  Future<void> init() async {}

  @override
  Future<User> signUp(UserParam? param) async {
    throw UnimplementedError();
  }

  @override
  Future<User> signIn(UserParam? param) async {
    developer.log('sign in...', name: 'FakeAuthRepository');
    switch (param!.signIn) {
      case SignIn.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (exception != null) {
          throw exception!;
        }
        _logouted = false;
        return _user;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(UserParam? param) async {
    developer.log('sign out...', name: 'FakeAuthRepository');
    // await Future.delayed(Duration(seconds: 1));
    _logouted = true;
  }

  @override
  Future<User> currentUser() async {
    developer.log('get current user...', name: 'FakeAuthRepository');
    await Future.delayed(Duration(seconds: 1));
    return _logouted ? LoggedOutUser() : _user;
  }

  @override
  void dispose() {
    developer.log('disposing...', name: 'FakeAuthRepository');
    signOut(UserParam(signIn: SignIn.withEmailAndPassword));
  }
}

@GenerateMocks([IOTHubService, FirebaseAuthRepository])
void main() {
  // late final mockAuth = MockFirebaseAuthRepository();
  setUp(() {
    IOTHubsMainPage.user.injectAuthMock(() => FakeAuthRepository());
    IOTHubsMainPage.iotHubService.injectMock(() => MockIOTHubService());
  });

  testWidgets('first sign in, success', (tester) async {
    //IOTHubsMainPage.user.auth.signIn((param) => UserParam(signIn: SignIn.withEmailAndPassword, email: 'x@y.cz', password: 'xxx')

    // late final testUser = User(uid: '1', email: 'x@y.cz', displayName: 'test');

    // when(mockAuth.init()).thenAnswer((_) async => null);
    // when(mockAuth.currentUser()).thenAnswer((_) async => Future.value(testUser));
    // when(mockAuth.dispose()).thenAnswer((_) {
    //   IOTHubsMainPage.user.auth.signOut(param: (param) => UserParam(signIn: SignIn.withEmailAndPassword));});
    // when(IOTHubsMainPage.user.auth.injected.onAuthStream).thenReturn((_) async => Future.delayed(Duration(seconds: 1)).then((_) => testUser).asStream());
    // when(IOTHubsMainPage.user.auth.signIn(argThat(isNotNull))).thenAnswer((_) async =>
    //     Future.delayed(Duration(seconds: 1)).then((_) => testUser));
    // when(IOTHubsMainPage.user.auth.signIn(argThat(isNull))).thenAnswer((_) async => Future.value(LoggedOutUser()));

    var iotHUBs = [IOTHub('Praha', id: '1'), IOTHub('VK', id: '2')];
    when(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).thenAnswer((_) async => Future.value(iotHUBs));

    await tester.pumpWidget(IOTHubApp());

    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.byType(TileNavigationButton).at(0));

    // Rebuild the widget after the state has changed.
    // await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.byType(IOTHubsMainPage), findsOneWidget);

    // await tester.pump(const Duration(milliseconds: 1000));

    // expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(IOTHubList), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));

    verify(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).called(1);
    // verifyNever(mockAuth.dispose());
    // verifyNever(IOTHubsMainPage.user.auth.signOut(param: anyNamed('param')));
  });
}
