import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/nas/nas_sync_page.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'nas_sync_page_test.mocks.dart';

@GenerateMocks([NASFileSyncService])
void main() {
  setUp(() {
    NASSyncMainPage.nasFileSyncState.injectMock(() => NASFileSyncState(MockNASFileSyncService()));
  });

  group('open nas sync page', () {
    testWidgets('first opened page', (tester) async {
      const nasFoldersRespData = ['path1', 'path2', 'path3'];
      when(NASSyncMainPage.nasFileSyncState.state.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => nasFoldersRespData));
      // when(NASSyncMainPage.nasFileSyncState.state.clearFiles()).thenReturn(null);

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Loading'), findsOneWidget);
      expect(find.byType(NASSyncMainPage), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // expect(find.byType(TextFormField), findsOneWidget);
      // expect(find.byType(DropdownMenuItem), findsNWidgets(nasFoldersRespData.length));
      expect(find.text(nasFoldersRespData[0]), findsOneWidget);
      expect(find.text(nasFoldersRespData[1]), findsOneWidget);
      expect(find.text(nasFoldersRespData[2]), findsOneWidget);
      // expect(find.byType(DropdownButtonFormField), findsOneWidget);
      // expect(find.byType(DropdownButton), findsOneWidget);

      verify(NASSyncMainPage.nasFileSyncState.state.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER)).called(1);
      // verify(NASSyncMainPage.nasFileSyncState.state.clearFiles()).called(1); //disposing state
    });
  });

  group('Form validators', () {
    testWidgets('load nas folders failed', (tester) async {
      const errorMsg = 'xxx';
      when(NASSyncMainPage.nasFileSyncState.state.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenThrow(NASFileException(errorMsg));
      // when(NASSyncMainPage.nasFileSyncState.state.clearFiles()).thenReturn(null);

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

      await tester.pump();
      await tester.pump();

      expect(find.byType(NASSyncMainPage), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(AlertDialog), findsOneWidget);

      expect(find.text(errorMsg), findsOneWidget);

      verify(NASSyncMainPage.nasFileSyncState.state.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER)).called(1);
      // verify(NASSyncMainPage.nasFileSyncState.state.clearFiles()).called(1); //disposing state
    });

    testWidgets('send files - not entered local path to synch dir', (tester) async {
      const nasFoldersRespData = ['path1', 'path2', 'path3'];
      when(NASSyncMainPage.nasFileSyncState.state.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1)).then((_) => nasFoldersRespData));
      // when(NASSyncMainPage.nasFileSyncState.state.clearFiles()).thenReturn(null);

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Loading'), findsOneWidget);
      expect(find.byType(NASSyncMainPage), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Cannot be empty'), findsNWidgets(2));
      expect(find.text('Transferred / All - '), findsNothing);

      verify(NASSyncMainPage.nasFileSyncState.state.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER)).called(1);
      // verify(NASSyncMainPage.nasFileSyncState.state.clearFiles()).called(1); //disposing state
    });
  });

}
