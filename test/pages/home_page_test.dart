import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/auth_repository.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/pages/iothub/iothubs.dart';
import 'package:iothub/src/ui/widgets/splash_screen.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([IOTHubService, FirebaseAuthRepository])
void main() {
  setUp(() {
    IOTHubsMainPage.user.injectAuthMock(() => MockFirebaseAuthRepository());
    IOTHubsMainPage.iotHubService.injectMock(() => MockIOTHubService());
  });

  testWidgets('display splash screen and go to home page', (tester) async {
    //IOTHubsMainPage.user.auth.signIn((param) => UserParam(signIn: SignIn.withEmailAndPassword, email: 'x@y.cz', password: 'xxx')

    when(IOTHubsMainPage.user.auth.signIn((param) => param!)).thenAnswer((_) async =>
        Future.delayed(Duration(seconds: 1)).then((_) => User(uid: '1', email: 'x@y.cz', displayName: 'test')));

    await tester.pumpWidget(const HomePage());

    await tester.tap(find.byType(TileNavigationButton).at(0));

    // Rebuild the widget after the state has changed.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SplashScreen), findsOneWidget);

    verify(IOTHubsMainPage.user.auth.signIn(any)).called(1);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(IOTHubList), findsOneWidget);
  });
}
