import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
import 'package:iothub/src/domain/entities/device.dart';
import 'package:iothub/src/domain/entities/iothub.dart';
import 'package:iothub/src/domain/entities/measured_property.dart';
import 'package:iothub/src/domain/entities/measurement.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/exceptions/database_exception.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/dashboard.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/pages/iothub/iothubs.dart';
import 'package:iothub/src/ui/widgets/dashboard_device_card.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/mockito.dart';

import 'iothub_main_test.mocks.dart';

void main() {
  // late final mockAuth = MockFirebaseAuthRepository();
  setUp(() {
    IOTHubsMainPage.user.injectAuthMock(() => MockFirebaseAuthRepository());
    IOTHubsMainPage.iotHubService.injectMock(() => MockIOTHubService());
  });

  group('Dashboard page', () {
    testWidgets('show dashboard success', (tester) async {
      //IOTHubsMainPage.user.auth.signIn((param) => UserParam(signIn: SignIn.withEmailAndPassword, email: 'x@y.cz', password: 'xxx')

      late final testUser = User(uid: '1', email: 'x@y.cz', displayName: 'test');

      final authRepo = IOTHubsMainPage.user.getRepoAs() as MockFirebaseAuthRepository;
      when(authRepo.init()).thenAnswer((_) async {});
      when(authRepo.currentUser()).thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => testUser));
      // when(IOTHubsMainPage.user.auth.injected.onAuthStream).thenReturn((_) async => Future.delayed(Duration(seconds: 1)).then((_) => testUser).asStream());
      when(authRepo.signIn(argThat(isNotNull)))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => testUser));

      when(authRepo.signOut(argThat(isNull)))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) {}));

      var iotHUBs = [IOTHub('1', 'Praha'), IOTHub('2', 'VK')];
      when(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).thenAnswer((_) async => Future.value(iotHUBs));
      var iotDevices = [Device('1', 'Teplomer1'), Device('2', 'Teplomer2')];
      when(IOTHubsMainPage.iotHubService.state.loadAllDevices(iotHUBs[0].id))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => iotDevices));
      var mProp = MeasuredProperty('temperature', 'C');
      var deviceLastMeasurement1 = [Measurement(mProp, 21.5)];
      var deviceLastMeasurement2 = [Measurement(mProp, 15.0)];
      when(IOTHubsMainPage.iotHubService.state.loadLastMeasurement(iotHUBs[0].id, iotDevices[0]))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => deviceLastMeasurement1));
      when(IOTHubsMainPage.iotHubService.state.loadLastMeasurement(iotHUBs[0].id, iotDevices[1]))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => deviceLastMeasurement2));

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(0)); //to iot hub app

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(IOTHubList), findsOneWidget);

      // await tester.pump();
      // await tester.pump();
      // await tester.pump();

      expect(find.byType(ListTile), findsNWidgets(2));
      await tester.tap(find.byType(ListTile).at(0));

      // await tester.tap(find.byIcon(Icons.arrow_back).at(1));

      // await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(IOTHubDashboardPage), findsOneWidget);
      expect(find.byType(DashboardDeviceCard), findsOneWidget);
      iotDevices.forEach((element) => expect(find.text(element.name), findsOneWidget));

      expect(find.textContaining(deviceLastMeasurement1.first.property.name), findsNWidgets(2));
      deviceLastMeasurement1.forEach((element) {
        expect(find.textContaining(element.value.toString()), findsOneWidget);
      });
      deviceLastMeasurement2.forEach((element) {
        expect(find.textContaining(element.value.toString()), findsOneWidget);
      });

      verify(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).called(1);
      verify(IOTHubsMainPage.iotHubService.state.loadAllDevices(iotHUBs[0].id)).called(1);
      verify(IOTHubsMainPage.iotHubService.state.loadLastMeasurement(iotHUBs[0].id, iotDevices[0])).called(1);
      verify(IOTHubsMainPage.iotHubService.state.loadLastMeasurement(iotHUBs[0].id, iotDevices[1])).called(1);
    });

    testWidgets('load all iothubs Firebase exception', (tester) async {
      final errorMsg = 'Test exception message';

      when(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs())
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => throw DatabaseException(errorMsg)));

      final Widget testWidget = MediaQuery(data: MediaQueryData(), child: MaterialApp(home: const IOTHubList()));

      await tester.pumpWidget(testWidget);
      expect(find.byType(IOTHubList), findsOneWidget);

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text(errorMsg), findsOneWidget);

      verify(IOTHubsMainPage.iotHubService.state.loadAllIOTHubs()).called(1);
    });
  });
}
