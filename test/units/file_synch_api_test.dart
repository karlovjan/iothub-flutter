import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/http_nas_file_sync_service.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/common/datetime_ext.dart';
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

      when(client.retrieveDirectoryItems(
              '/home/mbaros/projects/my/flutter/iothub/test/resources/nas', 0.0, 0.0, FileTypeForSync.image))
          .thenAnswer((_) => Future.delayed(
                Duration(seconds: 2),
                () => response,
              ));

      await httpService.getFilesForSynchronization('/home/mbaros/projects/my/flutter/iothub/test/resources/nas',
          'nas/folder/path', FileTypeForSync.image, DateTime.now().dateNow(), DateTime.now());

      expect(httpService.allTransferringFilesCount, 3);
      expect(httpService.filesForUploading[0] is File, true);
      // expect(files[0].lastModified, DateTime(2020, 10, 14, 22, 9, 32));
      expect(httpService.filesForUploading[0].path.endsWith('file1.txt'), true);
    });

    test('nas target folder does not exist', () async {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      when(client.retrieveDirectoryItems(argThat(isNull), 0.0, 0.0, FileTypeForSync.image))
          .thenAnswer((_) async => throw NASFileException('wrong file'));

      expect(
          httpService.getFilesForSynchronization(
              'xxxPath', 'nas/folder/path', FileTypeForSync.image, DateTime.now().dateNow(), DateTime.now()),
          throwsA(isA<NASFileException>()));
    });
  });

  group('send file to the nas server', () {
    final nasFolder = 'test/resources/nas';

    setUp(() {});

    tearDown(() {});

    test('transfer file to the target location from local', () async {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      final transferringFiles = [File('file1.img'), File('file2.img'), File('file3.img')];

      final transferredFiles = [
        UploadFileStatus(uploadingFilePath: 'file1.img', timestamp: DateTime.now(), uploaded: true),
        UploadFileStatus(uploadingFilePath: 'file2.img', timestamp: DateTime.now(), uploaded: true),
        UploadFileStatus(uploadingFilePath: 'file3.img', timestamp: DateTime.now(), uploaded: true)
      ];

      when(client.sendFiles(argThat(isNotEmpty), nasFolder, FileTypeForSync.image))
          .thenAnswer((_) => Stream.fromIterable(transferredFiles));

      final syncResultStream = await httpService.syncFolderWithNAS(transferringFiles, nasFolder, FileTypeForSync.image);

      final uploadFileStatusStreamList = [
        UploadFileStatus(uploadingFilePath: 'file1.img', timestamp: DateTime.now(), uploaded: false),
        UploadFileStatus(uploadingFilePath: 'file1.img', timestamp: DateTime.now(), uploaded: true),
        UploadFileStatus(uploadingFilePath: 'file2.img', timestamp: DateTime.now(), uploaded: false),
        UploadFileStatus(uploadingFilePath: 'file2.img', timestamp: DateTime.now(), uploaded: true),
        UploadFileStatus(uploadingFilePath: 'file3.img', timestamp: DateTime.now(), uploaded: false),
        UploadFileStatus(uploadingFilePath: 'file3.img', timestamp: DateTime.now(), uploaded: true)
      ];

      expect(syncResultStream, emitsInOrder(uploadFileStatusStreamList));
    });

    test('nothing to transfer', () async {
      final client = NASFileSyncServiceMockClient();
      final httpService = NASFileSyncState(client);

      final transferringFiles = const <File>[];

      when(client.sendFiles(argThat(isEmpty), nasFolder, FileTypeForSync.image)).thenAnswer((_) => Stream.empty());

      final syncResultStream = await httpService.syncFolderWithNAS(transferringFiles, nasFolder, FileTypeForSync.image);

      expect(syncResultStream, emitsInOrder([emitsDone]));
    });
  });
}
