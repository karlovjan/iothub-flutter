// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/ui/pages/home.dart';
import 'package:iothub/src/ui/pages/iot_hub_main_widget.dart';

void main() {
  /*
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(IOTHubMainWidged());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

   */

  testWidgets('Test main application is is started correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(IOTHubMainWidget());

    final defaultTitleFinder = find.text('IOT hub');
    final titleFinder = find.text('Praha dashboard');
    final messageFinder = find.text('Moje body: Moje grafy');

    expect(defaultTitleFinder, findsNothing);
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });

  testWidgets('Test default dashboard widged is shown',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(IOTHubMainWidget());

    final startingWidgetFinder = find.byType(HomePage);

    expect(startingWidgetFinder, findsOneWidget);
  });
}
