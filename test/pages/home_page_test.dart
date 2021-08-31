import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';

void main() {
  testWidgets('test home page', (tester) async {
    await tester.pumpWidget(IOTHubApp());

    //At start up the app should display a HomePage and a two TileNavigationButton
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(TileNavigationButton), findsNWidgets(2));
  });
}
