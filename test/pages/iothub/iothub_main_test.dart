import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
import 'package:iothub/src/data_source/auth_repository.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/exceptions/auth_exception.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/pages/iothub/iothubs.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'iothub_main_test.mocks.dart';

@GenerateMocks([FirebaseAuthRepository, IOTHubService])
void main() {
  setUp(() {
    IOTHubsMainPage.user.injectAuthMock(() => MockFirebaseAuthRepository());
    IOTHubsMainPage.iotHubService.injectMock(() => MockIOTHubService());
  });

  group('Sign in test', () {
    testWidgets('automatic first sign in, success', (tester) async {
      //IOTHubsMainPage.user.auth.signIn((param) => UserParam(signIn: SignIn.withEmailAndPassword, email: 'x@y.cz', password: 'xxx')

      late final testUser =
          User(uid: '1', email: 'x@y.cz', displayName: 'test');

      final authRepo =
          IOTHubsMainPage.user.getRepoAs() as MockFirebaseAuthRepository;
      when(authRepo.init()).thenAnswer((_) async => null);
      when(authRepo.currentUser()).thenAnswer((_) async =>
          Future.delayed(Duration(seconds: 1)).then((_) => testUser));
      // when(IOTHubsMainPage.user.auth.injected.onAuthStream).thenReturn((_) async => Future.delayed(Duration(seconds: 1)).then((_) => testUser).asStream());
      when(authRepo.signIn(argThat(isNotNull))).thenAnswer((_) async =>
          Future.delayed(Duration(seconds: 1)).then((_) => testUser));
      // when(IOTHubsMainPage.user.auth.signOut(param: argThat(isNotNull, named: 'param'))).thenAnswer((_) async =>
      //     Future.delayed(Duration(seconds: 1)).then((_) => null));
      // when(IOTHubsMainPage.user.auth.signIn(argThat(isNull))).thenAnswer((_) async => Future.value(LoggedOutUser()));

      var iotHUBs = [IOTHub('1', 'Praha'), IOTHub('2', 'VK')];
      when(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs())
          .thenAnswer((_) async => Future.value(iotHUBs));

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(0));

      // Rebuild the widget after the state has changed.
      await tester.pump();

      await tester.pump();

      expect(find.byType(IOTHubsMainPage), findsOneWidget);
      expect(find.byType(LoggingIndicator), findsOneWidget);

      var count = await tester.pumpAndSettle();
      // await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(IOTHubList), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));

      expect(IOTHubsMainPage.user.isSigned, true);

      verify(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).called(1);

      verify(authRepo.init()).called(1);
      verify(authRepo.currentUser()).called(1);
      verify(authRepo.signIn(argThat(isNotNull))).called(1);
      verifyNever(authRepo.signOut(argThat(isNotNull)));
      verifyNever(authRepo.dispose());
    });

    testWidgets('automatic first sign in exception', (tester) async {
      const errorMsg = 'Test error';
      final authRepo =
          IOTHubsMainPage.user.getRepoAs() as MockFirebaseAuthRepository;
      when(authRepo.init()).thenAnswer((_) async => null);
      when(authRepo.currentUser()).thenAnswer((_) async =>
          Future.delayed(Duration(seconds: 1)).then((_) => LoggedOutUser()));

      when(authRepo.signIn(argThat(isNotNull)))
          .thenThrow(AuthorizationException(errorMsg));

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(0));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(errorMsg), findsOneWidget);

      verify(authRepo.init()).called(1);
      verify(authRepo.currentUser()).called(1);
      verify(authRepo.signIn(argThat(isNotNull))).called(1);
    });
  });

  group('Sign out and disposing firebase app', () {
    testWidgets('sign out success', (tester) async {
      //IOTHubsMainPage.user.auth.signIn((param) => UserParam(signIn: SignIn.withEmailAndPassword, email: 'x@y.cz', password: 'xxx')

      late final testUser =
          User(uid: '1', email: 'x@y.cz', displayName: 'test');

      final authRepo =
          IOTHubsMainPage.user.getRepoAs() as MockFirebaseAuthRepository;
      when(authRepo.init()).thenAnswer((_) async {});
      when(authRepo.dispose()).thenReturn(() {});
      when(authRepo.currentUser()).thenAnswer((_) async =>
          Future.delayed(Duration(seconds: 1)).then((_) => testUser));
      // when(IOTHubsMainPage.user.auth.injected.onAuthStream).thenReturn((_) async => Future.delayed(Duration(seconds: 1)).then((_) => testUser).asStream());
      when(authRepo.signIn(argThat(isNotNull))).thenAnswer((_) async =>
          Future.delayed(Duration(seconds: 1)).then((_) => testUser));

      when(authRepo.signOut(argThat(isNull))).thenAnswer(
          (_) async => Future.delayed(Duration(seconds: 1)).then((_) {}));

      var iotHUBs = [IOTHub('1', 'Praha'), IOTHub('2', 'VK')];
      when(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs())
          .thenAnswer((_) async => Future.value(iotHUBs));

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(0));

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(IOTHubList), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));

      // await tester.pump();
      // await tester.pump();
      // await tester.pump();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // await tester.tap(find.byIcon(Icons.arrow_back).at(1));

      // await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(HomePage), findsOneWidget);

      verify(authRepo.currentUser()).called(1);

      expect(IOTHubsMainPage.user.isSigned, isFalse);
      expect(IOTHubsMainPage.user.state.uid, isEmpty);
      expect(IOTHubsMainPage.user.state, equals(LoggedOutUser()));

      verify(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).called(1);

      // verify(authRepo.dispose()).called(1);
      verify(authRepo.init()).called(1);
      // verifyNever(authRepo.currentUser()).called(5);
      verifyNever(authRepo.currentUser()); //TODO proc anijednou?
      verify(authRepo.signIn(argThat(isNotNull))).called(1);
      verify(authRepo.signOut(any)).called(1);
      verifyNever(authRepo.dispose());
      // verify(authRepo.dispose()).called(1);
    });
  });
}
