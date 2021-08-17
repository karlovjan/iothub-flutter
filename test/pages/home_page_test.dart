import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
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
  late final mockAuth = MockFirebaseAuthRepository();
  setUp(() {
    IOTHubsMainPage.user.injectAuthMock(() => mockAuth);
    IOTHubsMainPage.iotHubService.injectMock(() => MockIOTHubService());
  });

  testWidgets('display splash screen and go to home page', (tester) async {
    //IOTHubsMainPage.user.auth.signIn((param) => UserParam(signIn: SignIn.withEmailAndPassword, email: 'x@y.cz', password: 'xxx')

    late final testUser = User(uid: '1', email: 'x@y.cz', displayName: 'test');

    when(mockAuth.currentUser()).thenAnswer((_) async => Future.value(testUser));
    when(mockAuth.dispose()).thenAnswer((_) {
      IOTHubsMainPage.user.auth.signOut(param: (param) => UserParam(signIn: SignIn.withEmailAndPassword));});
    // when(IOTHubsMainPage.user.auth.injected.onAuthStream).thenReturn((_) async => Future.delayed(Duration(seconds: 1)).then((_) => testUser).asStream());
   /* when(IOTHubsMainPage.user.auth.signIn((param) {
      if(SignIn.withEmailAndPassword != param!.signIn){
        throw ArgumentError('expected SignIn.withEmailAndPassword', 'param signIn');
        }
      if(param.email!.isEmpty ){
        throw ArgumentError('email cannot be null', 'param email');
    }

      if(param.password!.isEmpty ){
        throw ArgumentError('password cannot be null', 'param password');
      }

      return param;
    })).thenAnswer((_) async =>
        Future.delayed(Duration(seconds: 1)).then((_) => testUser));
*/
    await tester.pumpWidget(IOTHubApp());

    await tester.tap(find.byType(TileNavigationButton).at(0));

    expect(find.byType(HomePage), findsOneWidget);

    // Rebuild the widget after the state has changed.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SplashScreen), findsOneWidget);


    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(IOTHubList), findsOneWidget);

    verify(IOTHubsMainPage.user.auth.signIn(any)).called(1);
    verify(mockAuth.currentUser()).called(1);
    verifyNever(mockAuth.dispose());
    verifyNever(IOTHubsMainPage.user.auth.signOut(param: anyNamed('param')));
  });
}
