import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/domain/value_objects/sync_form_data.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';

void main() {
  group('sync form data - json', () {
    test('to json and back', () async {
      final syncData = SyncFormData(
          'test',
          'local/folder',
          'remote/folder',
          DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 10))),
          DateUtils.dateOnly(DateTime.now()),
          FileTypeForSync.image);

      String json = syncData.toJson();

      print(json);

      final syncData2 = SyncFormData.fromJson(json);

      expect(syncData2, equals(syncData));
    });
  });
}
