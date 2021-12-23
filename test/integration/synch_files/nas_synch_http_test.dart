import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iothub/src/data_source/http_dio_nas_file_sync_service.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:path/path.dart' as path;
import 'package:iothub/src/service/common/datetime_ext.dart';

Future<void> main() async {
  final dio = Dio();

  dio.options
    ..baseUrl = 'https://smbrest.home/'
    ..connectTimeout = 5000 //5s
    ..receiveTimeout = 5000
    ..sendTimeout = 5000
    ..validateStatus = (int? status) {
      return status != null && status > 0;
    };

  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
  };

  Future<void> googleRequestTest() async {
    final response = await dio.get('https://www.google.com/');
    assert(response.data != null);
    assert(response.statusCode == 200);
  }

  Future<void> placeholderApiRequestTest() async {
    final response =
        await dio.get('https://jsonplaceholder.typicode.com/posts/1');
    assert(response.data != null);
    assert(response.statusCode == 200);
  }

  Future<void> listNasFoldersDioRequestTest() async {
    final response = await dio
        .post('/folders', data: {'path': NASFileSyncState.BASE_SAMBA_FOLDER});
    assert(response.data != null);
    assert(response.statusCode == 200);
  }

  // TestWidgetsFlutterBinding.ensureInitialized();

  final _httpClient = DIOHTTPNASFileSyncService(
      'smbrest.home',
      '/home/mbaros/projects/my/flutter/iothub/assets/certs/ca.crt',
      '/home/mbaros/projects/my/flutter/iothub/assets/certs/smbresthomeclient.p12');
  Future<void> listNasFoldersRequestTest() async {
    var folders =
        await _httpClient.listSambaFolders(NASFileSyncState.BASE_SAMBA_FOLDER);

    // final count = folders.length;
    assert(folders.length > 1);
  }

  Future<void> retrieveDirectoryItemsTest() async {
    final fullNasFolderPath =
        path.join(NASFileSyncState.BASE_SAMBA_FOLDER, 'phonePhotos/2021/');
    final fileTypeForSync = FileTypeForSync.image;
    final dateFrom = DateUtils.dateOnly(DateTime(2021, 6, 10));
    final dateTo = DateUtils.dateOnly(DateTime.now());
    final dateFromSeconds = dateFrom.secondsSinceEpoch;
    final dateToSeconds = dateTo.secondsSinceEpoch;

    var items = await _httpClient.retrieveDirectoryItems(
        fullNasFolderPath, dateFromSeconds, dateToSeconds, fileTypeForSync);

    // final count = folders.length;
    assert(items.length > 1);
  }

  Future<void> uploadFilesTest() async {
    final localDir = Directory('/home/mbaros/Pictures/test/');
    final localFilesStream =
        localDir.list(recursive: false, followLinks: false);
    final localFileList = <File>[];
    await for (FileSystemEntity entity in localFilesStream) {
      localFileList.add(File(entity.path));
    }
    print('Local files loaded...');
    // final localFiles = [File('/home/mbaros/Pictures/test/DSC03206.JPG'), File('/home/mbaros/Pictures/test/DSC02917.JPG')];
    final fullNasFolderPath =
        path.join(NASFileSyncState.BASE_SAMBA_FOLDER, 'test/');
    final fileTypeForSync = FileTypeForSync.image;
    await for (UploadFileStatus sentFile in _httpClient.sendFiles(
        localFileList, fullNasFolderPath, fileTypeForSync)) {
      if (sentFile.uploaded) {
        print('${sentFile.uploadingFilePath} uploaded');
      } else {
        print('${sentFile.uploadingFilePath} uploading started');
      }
    }
  }

  for (var i = 0; i < 1; i++) {
    // await uploadFilesTest();
    // await retrieveDirectoryItemsTest();
    // await listNasFoldersRequestTest();
    // await listNasFoldersDioRequestTest(); //nefunguje asi kvuli certifikatum
    // await googleRequestTest();
    print('$i. request');
  }
}
