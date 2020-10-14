import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/http_nas_file_sync_service.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';

void main() {
  group('file sync from device to nas', () {
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

    test('get nas target folder items', () async {
      final httpService = HTTPNASFileSyncService();

      final files =
          await httpService.retrieveDirectoryItems('/home/mbaros/projects/my/flutter/iothub/test/resources/nas');

      expect(files.length, 3);
      expect(files[0] is NASFileItem, true);
      // expect(files[0].lastModified, DateTime(2020, 10, 14, 22, 9, 32));
      expect(files[0].fileName, 'file3.txt');
    });

    test('nas target folder does not exist', () async {
      final httpService = HTTPNASFileSyncService();

      final files =
          await httpService.retrieveDirectoryItems('/home/mbaros/projects/my/flutter/iothub/test/resources/nasXXX');

      expect(files.length, 0);
    });
  });

  group('find out which file is a new to synchronize it ', () {
    test('find a new file', () {
      final httpService = HTTPNASFileSyncService();

      final targetFiles = <NASFileItem>[];
      targetFiles.add(NASFileItem('test1.txt', DateTime(2020, 10, 14, 22, 9, 32)));
      targetFiles.add(NASFileItem('test4.png', DateTime(2020, 10, 14, 22, 11, 00)));

      final sourceFolder = 'resources/nas';

      // List<NASFileItem> filesToTransfere = httpService.tete(targetFiles, sourceFolder);
    });

    test('find a modified file', () {
      final httpService = HTTPNASFileSyncService();
    });
  });

  group('send file to the nas server', () {
    test('transfer file to the target location', () {
      final httpService = HTTPNASFileSyncService();
    });
  });
}
