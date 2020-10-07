import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/http_nas_file_sync_service.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';

void main() {
  group('file sync from device to nas', () {
    test('get nas target folder items', () async {

      final httpService = HTTPNASFileSyncService();
      
      final files = await httpService.retrieveDirectoryItems('/home/mbaros/Documents/scripts');

      expect(files.length, 13);
      expect(files[0] is NASFileItem, true);
      expect(files[0].lastModified, DateTime(2017, 5, 30, 10, 18, 14));

    });

    test('nas target folder does not exist', () async {

      final httpService = HTTPNASFileSyncService();

      final files = await httpService.retrieveDirectoryItems('/home/mbaros/Documents/scriptsXXX');

      expect(files.length, 0);

    });

  });
}