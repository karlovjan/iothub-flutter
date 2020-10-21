import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/http_nas_file_sync_service.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/sync_folder_result.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:mockito/mockito.dart';

class NASFileSyncServiceMockClient extends Mock implements HTTPNASFileSyncService {}

void main() {
  group('file sync from device to nas', () {
    /*
    setUp(() async {
      // Creates dir/ and dir/subdir/.
      // new Directory('dir/subdir').create(recursive: true)

      final path = 'test/resources/nas';
      var myFile = File('${path}/file1.txt');
      await myFile.create(recursive: true);
      myFile = File('${path}/file2.txt');
      await myFile.create();
      myFile = File('${path}/file3.txt');
      await myFile.create();
    });

    tearDown(() async {
      await Directory('test/resources/nas/').delete(recursive: true);
    });

     */

    test('get nas target folder items', () async {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      final response = [
        NASFileItem('file1.txt', DateTime.now()),
        NASFileItem('file2.txt', DateTime.now()),
        NASFileItem('file3.txt', DateTime.now())
      ];

      when(client.retrieveDirectoryItems('/home/mbaros/projects/my/flutter/iothub/test/resources/nas'))
          .thenAnswer((_) => Future.delayed(
                Duration(seconds: 2),
                () => response,
              ));

      final files =
          await httpService.retrieveRemoteDirectoryItems('/home/mbaros/projects/my/flutter/iothub/test/resources/nas');

      expect(files.length, 3);
      expect(files[0] is NASFileItem, true);
      // expect(files[0].lastModified, DateTime(2020, 10, 14, 22, 9, 32));
      expect(files[0].fileName, 'file1.txt');
    });

    test('nas target folder not set', () {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      when(client.retrieveDirectoryItems(null)).thenAnswer((_) => Future.sync(
            () => throw NASFileException('test'),
          ));

      expect(httpService.retrieveRemoteDirectoryItems(null), throwsA(NASFileException));
    });

    test('nas target folder does not exist', () {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      when(client.retrieveDirectoryItems('xxxFolder')).thenAnswer((_) => Future.sync(
            () => throw NASFileException('test'),
          ));

      expect(httpService.retrieveRemoteDirectoryItems('xxxFolder'), throwsA(NASFileException));
    });
  });

  group('find out which file is a new to synchronize it ', () {
    setUp(() async {
      // Creates dir/ and dir/subdir/.
      // new Directory('dir/subdir').create(recursive: true)

      final path = 'test/resources/local';
      var myFile = File('${path}/file1.txt');
      await myFile.create(recursive: true);
      myFile = File('${path}/file2.txt');
      await myFile.create();
      myFile = File('${path}/file3.txt');
      await myFile.create();
      myFile = File('${path}/file4.txt');
      await myFile.create();
    });

    tearDown(() async {
      await Directory('test/resources/local/').delete(recursive: true);
    });

    test('find a new file', () async {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      final targetFiles = <NASFileItem>[];
      targetFiles.add(NASFileItem('file2.txt', DateTime(2020, 10, 14, 22, 9, 32)));
      targetFiles.add(NASFileItem('file4.txt', DateTime(2020, 10, 14, 22, 11, 00)));

      final sourceFolder = 'test/resources/local';

      final filesToTransfer = await httpService.getFilesForSynchronization(targetFiles, sourceFolder);

      expect(filesToTransfer.length, 2);
      expect(filesToTransfer[0] is File, true);
      // expect(files[0].lastModified, DateTime(2020, 10, 14, 22, 9, 32));
      expect(filesToTransfer[0].path, '${sourceFolder}/file3.txt');
      expect(filesToTransfer[1].path, '${sourceFolder}/file1.txt');
    });

    test('wrong input parameters', () {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      expect(httpService.getFilesForSynchronization(null, null), throwsAssertionError);
      expect(httpService.getFilesForSynchronization([NASFileItem('fileName', null)], null), throwsAssertionError);
    });
  });

  group('send file to the nas server', () {

    final localFolder = 'test/resources/local';
    final nasFolder = 'test/resources/nas';

    setUp(() async {
      // Creates dir/ and dir/subdir/.
      // new Directory('dir/subdir').create(recursive: true)

      var myFile = File('${localFolder}/file1.txt');
      await myFile.create(recursive: true);
      myFile = File('${localFolder}/file2.txt');
      await myFile.create();
      myFile = File('${localFolder}/file3.txt');
      await myFile.create();
      myFile = File('${localFolder}/file4.txt');
      await myFile.create();

      myFile = File('${nasFolder}/file4.txt');
      await myFile.create(recursive: true);

    });

    tearDown(() async {
      await Directory(localFolder).delete(recursive: true);
      await Directory(nasFolder).delete(recursive: true);
    });

    test('transfer file to the target location from local', () async {

      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      final responseListNasFolder = [
        NASFileItem('file4.txt', DateTime.now())
      ];

      final responseSync = SyncFolderResult(sourceFolderPath: localFolder, targetFolderPath: nasFolder, transferredFileCount: 4);

      when(client.retrieveDirectoryItems(nasFolder))
          .thenAnswer((_) => Future.delayed(
        Duration(seconds: 1),
            () => responseListNasFolder,
      ));


      when(client.syncFolderWithNAS(localFolder, nasFolder))
          .thenAnswer((_) => Future.delayed(
        Duration(seconds: 1),
            () => responseSync,
      ));

      final result = await httpService.syncFolderWithNAS(localFolder, nasFolder);

      expect(result.sourceFolderPath, localFolder);
      expect(result.targetFolderPath, nasFolder);
      expect(result.transferredFileCount, 3);

      final filesToTransfer = await httpService.getFilesForSynchronization(List.empty(), localFolder);

      expect(filesToTransfer.length, 4);
      expect(filesToTransfer[0].path, '${localFolder}/file3.txt');

    });
  });
}
