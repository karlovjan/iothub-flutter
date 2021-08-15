import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/domain/entities/user.dart';
import 'package:iothub/src/service/interfaces/iothub_repository.dart';
import 'package:iothub/src/service/iothub_service.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/iothub/iothub_main.dart';
import 'package:iothub/src/ui/widgets/splash_screen.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/mockito.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class FakeUserRepository extends Mock implements IAuth<User, UserParam> {}
class FakeIOTHubService extends Mock implements IOTHubService {}

void main() {
  setUp(() {
    IOTHubsMainPage.user.injectAuthMock(() => FakeUserRepository());
    IOTHubsMainPage.iotHubService.injectMock(() => FakeIOTHubService());

  });

  testWidgets('display splash screen and go to home page', (tester) async {
    await tester.pumpWidget(const HomePage());

    await tester.tap(find.byType(TileNavigationButton).at(0));


    expect(find.byType(SplashScreen), findsOneWidget);


    // Rebuild the widget after the state has changed.
    // await tester.pump();

  });
}