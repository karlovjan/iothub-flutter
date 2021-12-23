import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/main.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/common/datetime_ext.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/local_file_system_service.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:iothub/src/ui/pages/home_page/home_page.dart';
import 'package:iothub/src/ui/pages/nas/nas_sync_page.dart';
import 'package:iothub/src/ui/widgets/data_loader_indicator.dart';
import 'package:iothub/src/ui/widgets/tile_navigation_button.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:states_rebuilder/states_rebuilder.dart';

import 'nas_sync_page_test.mocks.dart';

@GenerateMocks([NASFileSyncService, LocalFileSystemService])
void main() {
  final _mockService = MockNASFileSyncService();
  final _mockLocalFileSystem = MockLocalFileSystemService();
  setUp(() {
    NASSyncMainPage.nasFileSyncState
        .injectMock(() => NASFileSyncState(_mockService, _mockLocalFileSystem));
  });

  group('open nas sync page', () {
    testWidgets('first opened page', (tester) async {
      const nasFoldersRespData = ['path1', 'path2', 'path3'];
      when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
              .then((_) => nasFoldersRespData));
      // when(NASSyncMainPage.nasFileSyncState.state.clearFiles()).thenReturn(null);

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester
          .tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

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

      verify(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .called(1);
    });
  });

  group('Form validators', () {
    testWidgets('loading nas folders fails', (tester) async {

      const errorMsg = 'test error';
      when(_mockService.listSambaFolders(argThat(isNotNull)))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
          .then((_) => throw NASFileException(errorMsg)));

      await tester.pumpWidget(MaterialApp(home: NASSyncMainPage(),));
      expect(find.byType(NASSyncMainPage), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(errorMsg), findsOneWidget);
      expect(find.text('Select NAS folder'), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      verify(_mockService.listSambaFolders(argThat(isNotNull)))
          .called(1);
    });

    testWidgets('send files - not entered local path to synch dir',
        (tester) async {
      const nasFoldersRespData = ['path1', 'path2', 'path3'];
      when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
              .then((_) => nasFoldersRespData));
      // when(NASSyncMainPage.nasFileSyncState.state.clearFiles()).thenReturn(null);

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester
          .tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Loading'), findsOneWidget);
      expect(find.byType(NASSyncMainPage), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Cannot be empty'), findsNWidgets(2));
      expect(find.text('Transferred / All - '), findsNothing);

      verify(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .called(1);
    });
  });

  group('Show files to transfer', () {
    testWidgets('default form values', (tester) async {
      const nasFoldersRespData = ['path1', 'path2', 'path3'];
      when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
              .then((_) => nasFoldersRespData));

      final localFolderPath = 'localPath';
      final nasFolderPath = nasFoldersRespData.elementAt(1);
      final fullNasFolderPath =
          p.join(NASFileSyncState.BASE_SAMBA_FOLDER, nasFolderPath);
      final fileTypeForSync = FileTypeForSync.image;
      final dateFrom =
          DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 5)));
      final dateTo = DateUtils.dateOnly(DateTime.now());
      final dateFromSeconds = dateFrom.secondsSinceEpoch;
      final dateToSeconds = dateTo.secondsSinceEpoch;

      final localFile1 = 'file1';
      final localFile2 = 'file2';
      final localFile3 = 'file3';
      final localFiles = [File(localFile1), File(localFile2)];

      final targetFiles = <NASFileItem>[
        NASFileItem(localFile1, dateFrom),
        NASFileItem(localFile2, dateFrom.add(const Duration(days: 1))),
        NASFileItem(localFile3, dateFrom.add(const Duration(days: 2)))
      ];

      when(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
              fileTypeForSync, dateFrom, dateTo, targetFiles))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
              .then((_) => localFiles));
      // when(_mockState.clearFiles()).thenReturn(null);

      when(_mockService.retrieveDirectoryItems(fullNasFolderPath,
              dateFromSeconds, dateToSeconds, fileTypeForSync))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
              .then((_) => targetFiles));

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester
          .tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Loading server folders ...'), findsOneWidget);
      expect(find.byType(NASSyncMainPage), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      verify(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .called(1);

      expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
          equals(0));
      expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
          equals(0));
      expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
          equals(0));

      //enter local path
      await tester.enterText(find.byType(EditableText).first, localFolderPath);

      //set date time from - end is now()
      final fromDateString = '${dateFrom.month}/${dateFrom.day}/${dateFrom.year}';
      await tester.enterText(
          find.byType(InputDatePickerFormField).first, fromDateString);
      await tester.pumpAndSettle();
      expect(find.text(fromDateString), findsOneWidget);

      //tap second DropdownButtonFormField Item
      await tester.tap(find.text('Select NAS folder'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text(nasFolderPath).last);

      await tester.pumpAndSettle();

      //textove pole obsahuje zadany text cesty k lokalnim souborum
      expect(find.text(localFolderPath), findsOneWidget);

      await tester.tap(find.text('Show files'));
      expect(find.text('Waiting for files to synchronize...'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Waiting for files to synchronize...'), findsNothing);
      expect(find.byType(CommonDataLoadingIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(nasFolderPath), findsOneWidget);

      expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
          equals(2));
      expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
          equals(2));
      expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
          equals(2));

      expect(find.byKey(ValueKey(localFile1)), findsOneWidget);
      expect(find.byKey(ValueKey(localFile2)), findsOneWidget);
      //it was matched only two local files to transfer to NAS the third one must not be seen.
      expect(find.byKey(ValueKey(localFile3)), findsNothing);

      verifyNever(
          _mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER));
      verify(_mockService.retrieveDirectoryItems(fullNasFolderPath,
              dateFromSeconds, dateToSeconds, fileTypeForSync))
          .called(1);
      verify(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
              fileTypeForSync, dateFrom, dateTo, targetFiles))
          .called(1);
    });

  });

  group('Upload files showing files', () {
    testWidgets('upload all showing files successfully', (tester) async {
      const nasFoldersRespData = ['path1', 'path2', 'path3'];
      when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
          .then((_) => nasFoldersRespData));

      final localFolderPath = 'localPath';
      final nasFolderPath = nasFoldersRespData.elementAt(1);
      final fullNasFolderPath =
      p.join(NASFileSyncState.BASE_SAMBA_FOLDER, nasFolderPath);
      final fileTypeForSync = FileTypeForSync.image;
      final dateFrom =
      DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 5)));
      final dateTo = DateUtils.dateOnly(DateTime.now());
      final dateFromSeconds = dateFrom.secondsSinceEpoch;
      final dateToSeconds = dateTo.secondsSinceEpoch;

      final localFile1 = 'file1';
      final localFile2 = 'file2';
      final localFile3 = 'file3';
      final localFiles = [File(localFile1), File(localFile2)];

      final targetFiles = <NASFileItem>[
        NASFileItem(localFile1, dateFrom),
        NASFileItem(localFile2, dateFrom.add(const Duration(days: 1))),
        NASFileItem(localFile3, dateFrom.add(const Duration(days: 2)))
      ];

      when(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
          fileTypeForSync, dateFrom, dateTo, targetFiles))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
          .then((_) => localFiles));

      when(_mockService.retrieveDirectoryItems(fullNasFolderPath,
          dateFromSeconds, dateToSeconds, fileTypeForSync))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
          .then((_) => targetFiles));

      //prenaseny soubor: jeho status se vrati pred odeslanim na NAS a pak hned jak se provede upload
      final uploadingFiles = <Future<UploadFileStatus>>[
        Future.value(UploadFileStatus(uploadingFilePath: localFile1, timestamp: DateTime.now())),
        Future.delayed(const Duration(seconds: 1)).then((value) => UploadFileStatus(uploadingFilePath: localFile1, timestamp: DateTime.now(), uploaded: true)),
        Future.value(UploadFileStatus(uploadingFilePath: localFile2, timestamp: DateTime.now())),
        Future.delayed(const Duration(seconds: 1)).then((value) => UploadFileStatus(uploadingFilePath: localFile2, timestamp: DateTime.now(), uploaded: true)),
      ];
      when(_mockService.sendFiles(localFiles, fullNasFolderPath, fileTypeForSync)).thenAnswer((realInvocation) => Stream.fromFutures(uploadingFiles));

      await tester.pumpWidget(IOTHubApp());
      await tester.pumpAndSettle();

      await tester
          .tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

      await tester.pumpAndSettle(const Duration(seconds: 1));

      //enter local path
      await tester.enterText(find.byType(EditableText).first, localFolderPath);

      //set date time from - end is now()
      final fromDateString = '${dateFrom.month}/${dateFrom.day}/${dateFrom.year}';
      await tester.enterText(
          find.byType(InputDatePickerFormField).first, fromDateString);
      await tester.pumpAndSettle();

      //tap second DropdownButtonFormField Item
      await tester.tap(find.text('Select NAS folder'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text(nasFolderPath).last);

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show files'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      //states before uploading
      expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
          equals(2));
      expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
          equals(2));
      expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
          equals(2));

      expect(find.byKey(ValueKey(localFile1)), findsOneWidget);
      expect(find.byKey(ValueKey(localFile2)), findsOneWidget);
      //it was matched only two local files to transfer to NAS the third one must not be seen.
      expect(find.byKey(ValueKey(localFile3)), findsNothing);


      //Click on Upload button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // expect(find.text('Cannot be empty'), findsNWidgets(2));
      expect(find.text('Transferred / All - '), findsOneWidget);

      expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
          equals(0));
      expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
          equals(0));
      expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
          equals(0));
      expect(NASSyncMainPage.nasFileSyncState.state.transferredFilesCount,
          equals(2));

      expect(find.byKey(ValueKey(localFile1)), findsNothing);
      expect(find.byKey(ValueKey(localFile2)), findsNothing);


      verify(
          _mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER)).called(1);
      verify(_mockService.retrieveDirectoryItems(fullNasFolderPath,
          dateFromSeconds, dateToSeconds, fileTypeForSync))
          .called(1);
      verify(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
          fileTypeForSync, dateFrom, dateTo, targetFiles))
          .called(1);

      verify(_mockService.sendFiles(localFiles, fullNasFolderPath, fileTypeForSync)).called(1);

    });


  });

  testWidgets('upload all files successfully - no sowing files', (tester) async {
    const nasFoldersRespData = ['path1', 'path2', 'path3'];
    when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
        .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
        .then((_) => nasFoldersRespData));

    final localFolderPath = 'localPath';
    final nasFolderPath = nasFoldersRespData.elementAt(1);
    final fullNasFolderPath =
    p.join(NASFileSyncState.BASE_SAMBA_FOLDER, nasFolderPath);
    final fileTypeForSync = FileTypeForSync.image;
    final dateFrom =
    DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 5)));
    final dateTo = DateUtils.dateOnly(DateTime.now());
    final dateFromSeconds = dateFrom.secondsSinceEpoch;
    final dateToSeconds = dateTo.secondsSinceEpoch;

    final localFile1 = 'file1';
    final localFile2 = 'file2';
    final localFile3 = 'file3';
    final localFiles = [File(localFile1), File(localFile2)];

    final targetFiles = <NASFileItem>[
      NASFileItem(localFile1, dateFrom),
      NASFileItem(localFile2, dateFrom.add(const Duration(days: 1))),
      NASFileItem(localFile3, dateFrom.add(const Duration(days: 2)))
    ];

    when(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
        fileTypeForSync, dateFrom, dateTo, targetFiles))
        .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
        .then((_) => localFiles));

    when(_mockService.retrieveDirectoryItems(fullNasFolderPath,
        dateFromSeconds, dateToSeconds, fileTypeForSync))
        .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
        .then((_) => targetFiles));

    //prenaseny soubor: jeho status se vrati pred odeslanim na NAS a pak hned jak se provede upload
    final uploadingFiles = <Future<UploadFileStatus>>[
      Future.value(UploadFileStatus(uploadingFilePath: localFile1, timestamp: DateTime.now())),
      Future.delayed(const Duration(seconds: 1)).then((value) => UploadFileStatus(uploadingFilePath: localFile1, timestamp: DateTime.now(), uploaded: true)),
      Future.value(UploadFileStatus(uploadingFilePath: localFile2, timestamp: DateTime.now())),
      Future.delayed(const Duration(seconds: 1)).then((value) => UploadFileStatus(uploadingFilePath: localFile2, timestamp: DateTime.now(), uploaded: true)),
    ];
    when(_mockService.sendFiles(localFiles, fullNasFolderPath, fileTypeForSync)).thenAnswer((realInvocation) => Stream.fromFutures(uploadingFiles));

    await tester.pumpWidget(IOTHubApp());
    await tester.pumpAndSettle();

    await tester
        .tap(find.byType(TileNavigationButton).at(1)); //to nas sync app

    await tester.pumpAndSettle(const Duration(seconds: 1));

    //enter local path
    await tester.enterText(find.byType(EditableText).first, localFolderPath);

    //set date time from - end is now()
    final fromDateString = '${dateFrom.month}/${dateFrom.day}/${dateFrom.year}';
    await tester.enterText(
        find.byType(InputDatePickerFormField).first, fromDateString);
    await tester.pumpAndSettle();

    //tap second DropdownButtonFormField Item
    await tester.tap(find.text('Select NAS folder'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text(nasFolderPath).last);

    await tester.pumpAndSettle();

    //Click on Upload button
    await tester.tap(find.byType(FloatingActionButton));

    //inside FAB action is state not updated

    await tester.pumpAndSettle();


    // expect(find.text('Cannot be empty'), findsNWidgets(2));
    expect(find.text('Transferred / All - '), findsOneWidget);

    expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
        equals(0));
    expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
        equals(0));
    expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
        equals(0));
    expect(NASSyncMainPage.nasFileSyncState.state.transferredFilesCount,
        equals(2));

    expect(find.byKey(ValueKey(localFile1)), findsNothing);
    expect(find.byKey(ValueKey(localFile2)), findsNothing);


    verify(
        _mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER)).called(1);
    verify(_mockService.retrieveDirectoryItems(fullNasFolderPath,
        dateFromSeconds, dateToSeconds, fileTypeForSync))
        .called(1);
    verify(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
        fileTypeForSync, dateFrom, dateTo, targetFiles))
        .called(1);

    verify(_mockService.sendFiles(localFiles, fullNasFolderPath, fileTypeForSync)).called(1);

  });


  testWidgets('show files gets error', (tester) async {

    const errorMsg = 'retrieveDirectoryItems error';
    const nasFoldersRespData = ['path1', 'path2', 'path3'];
    when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
        .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
        .then((_) => nasFoldersRespData));

    when(_mockService.retrieveDirectoryItems(argThat(isNotEmpty),
        argThat(isNotNull), argThat(isNotNull), argThat(isNotNull)))
        .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
        .then((_) => throw NASFileException(errorMsg)));


    await tester.pumpWidget(MaterialApp(navigatorKey: RM.navigate.navigatorKey, home: NASSyncMainPage(),));
    expect(find.byType(NASSyncMainPage), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
        equals(0));

    await tester.enterText(find.byType(EditableText).first, 'path/file');

    //set date time from - end is now()
    final fromDateString = '10/25/2021';
    await tester.enterText(
        find.byType(InputDatePickerFormField).first, fromDateString);

    //tap second DropdownButtonFormField Item
    await tester.tap(find.text('Select NAS folder'), warnIfMissed: false);
    await tester.pumpAndSettle();
    final nasFolderPath = nasFoldersRespData.elementAt(1);
    await tester.tap(find.text(nasFolderPath).last);

    await tester.pumpAndSettle();

    await tester.tap(find.text('Show files'));
    await tester.pumpAndSettle(const Duration(seconds: 3));


    expect(find.text(errorMsg), findsOneWidget);

    verify(_mockService.listSambaFolders(argThat(isNotEmpty)))
        .called(1);
  });

  testWidgets('clear showing files', (tester) async {
    const nasFoldersRespData = ['path1', 'path2', 'path3'];
    when(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
        .thenAnswer((_) => Future.delayed(Duration(seconds: 1))
        .then((_) => nasFoldersRespData));

    final localFolderPath = 'localPath';
    final nasFolderPath = nasFoldersRespData.elementAt(1);
    final fullNasFolderPath =
    p.join(NASFileSyncState.BASE_SAMBA_FOLDER, nasFolderPath);
    final fileTypeForSync = FileTypeForSync.image;
    final dateFrom =
    DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 5)));
    final dateTo = DateUtils.dateOnly(DateTime.now());
    final dateFromSeconds = dateFrom.secondsSinceEpoch;
    final dateToSeconds = dateTo.secondsSinceEpoch;

    final localFile1 = 'file1';
    final localFile2 = 'file2';
    final localFile3 = 'file3';
    final localFiles = [File(localFile1), File(localFile2)];

    final targetFiles = <NASFileItem>[
      NASFileItem(localFile1, dateFrom),
      NASFileItem(localFile2, dateFrom.add(const Duration(days: 1))),
      NASFileItem(localFile3, dateFrom.add(const Duration(days: 2)))
    ];

    when(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
        fileTypeForSync, dateFrom, dateTo, targetFiles))
        .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
        .then((_) => localFiles));
    // when(_mockState.clearFiles()).thenReturn(null);

    when(_mockService.retrieveDirectoryItems(fullNasFolderPath,
        dateFromSeconds, dateToSeconds, fileTypeForSync))
        .thenAnswer((_) => Future.delayed(const Duration(seconds: 1))
        .then((_) => targetFiles));

    await tester.pumpWidget(MaterialApp(home: NASSyncMainPage(),));
    expect(find.byType(NASSyncMainPage), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    verify(_mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER))
        .called(1);

    expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
        equals(0));
    expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
        equals(0));
    expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
        equals(0));

    //enter local path
    await tester.enterText(find.byType(EditableText).first, localFolderPath);

    //set date time from - end is now()
    final fromDateString = '${dateFrom.month}/${dateFrom.day}/${dateFrom.year}';
    await tester.enterText(
        find.byType(InputDatePickerFormField).first, fromDateString);
    await tester.pumpAndSettle();
    expect(find.text(fromDateString), findsOneWidget);

    //tap second DropdownButtonFormField Item
    await tester.tap(find.text('Select NAS folder'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text(nasFolderPath).last);

    await tester.pumpAndSettle();

    //textove pole obsahuje zadany text cesty k lokalnim souborum
    expect(find.text(localFolderPath), findsOneWidget);

    await tester.tap(find.text('Show files'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // await tester.pumpAndSettle();

    expect(find.text(nasFolderPath), findsOneWidget);

    expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
        equals(2));
    expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
        equals(2));
    expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
        equals(2));

    expect(find.byKey(ValueKey(localFile1)), findsOneWidget);
    expect(find.byKey(ValueKey(localFile2)), findsOneWidget);
    //it was matched only two local files to transfer to NAS the third one must not be seen.
    expect(find.byKey(ValueKey(localFile3)), findsNothing);

    await tester.tap(find.text('Clear files'));
    // await tester.pump();
    // await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(NASSyncMainPage.nasFileSyncState.state.allTransferringFilesCount,
        equals(2));
    expect(NASSyncMainPage.nasFileSyncState.state.filesForUploading.length,
        equals(2));
    expect(NASSyncMainPage.nasFileSyncState.state.transferringFileList.length,
        equals(0));

    expect(find.byKey(ValueKey(localFile1)), findsNothing);
    expect(find.byKey(ValueKey(localFile2)), findsNothing);


    verifyNever(
        _mockService.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER));
    verify(_mockService.retrieveDirectoryItems(fullNasFolderPath,
        dateFromSeconds, dateToSeconds, fileTypeForSync))
        .called(1);
    verify(_mockLocalFileSystem.matchLocalFiles(localFolderPath, false,
        fileTypeForSync, dateFrom, dateTo, targetFiles))
        .called(1);
  });

}
