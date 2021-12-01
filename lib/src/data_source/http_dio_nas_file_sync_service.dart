import 'dart:io';
import 'dart:typed_data';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/common/datetime_ext.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';

class DIOHTTPNASFileSyncService implements NASFileSyncService {
  DIOHTTPNASFileSyncService(
      this._serverName, this._caCertPath, this._pkcs12Path);

  final String _serverName;
  final String _caCertPath;
  final String _pkcs12Path;
  final _cancelRequestToken = CancelToken();

  //https://en.wikipedia.org/wiki/Cross-site_request_forgery
  //https://dev.to/matheusguimaraes/fast-way-to-enable-cors-in-flask-servers-42p0

  late final _baseOptions = BaseOptions(
    baseUrl: 'https://${_serverName}',
    responseType: ResponseType.json,
    contentType: Headers.formUrlEncodedContentType,
    connectTimeout: 5000,
    receiveTimeout: 5000,
    sendTimeout: 5000,
  );

  late final _httpSecurityContext = _createSecurityContext();

  Future<ByteData> _loadFile(String path) async {
    //is  the resource requested from within flutter app
    if (path.startsWith('assets')) {
      return await rootBundle.load('assets/certs/ca.crt');
    }
    //for tests or for certificates out of flutter app
    final bytes = await File(path).readAsBytes(); // Uint8List
    return bytes.buffer.asByteData(); // ByteData
  }

  Future<ByteData> _loadCACert() async {
//public certificate of CA
    return _loadFile(_caCertPath);
  }

  Future<ByteData> _loadPKCS12() async {
//client a kew and certificate package
    return _loadFile(_pkcs12Path);
  }

  Future<SecurityContext> _createSecurityContext() async {
// final sc = SecurityContext(withTrustedRoots: true);
    final sc = SecurityContext.defaultContext;

    try {
      final cacertBytes = await _loadCACert();
      sc.setTrustedCertificatesBytes(cacertBytes.buffer.asUint8List());

      final p12 = await _loadPKCS12();
      sc.usePrivateKeyBytes(p12.buffer.asUint8List());
      sc.useCertificateChainBytes(p12.buffer.asUint8List());
    } catch (err) {
      print('Caught error: $err');
      throw NASFileException('load certificates error: ${err}');
    }

    return sc;
  }

  @override
  Future<List<NASFileItem>> retrieveDirectoryItems(
      String folderPath,
      double dateFromSeconds,
      double dateToSeconds,
      FileTypeForSync fileTypeForSync) async {
    if (folderPath.trim().isEmpty) {
      print('folder is not set');
      throw NASFileException('Empty folder path');
    }

    final sc = await _httpSecurityContext;

    final dioClient = Dio(_baseOptions);

    (dioClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      return HttpClient(context: sc);
    };

    try {
//or works once
      final response = await dioClient.post('/folderItems', data: {
        'path': folderPath,
        'from': dateFromSeconds,
        'to': dateToSeconds,
        'type': describeEnum(fileTypeForSync)
      });

      if (response.statusCode == 200) {
        // Use the compute function to run parsePhotos in a separate isolate.
        // return compute(_parseNASFileItems, response.data.toString());
        // return _parseNASFileItems(await response.transform(utf8.decoder).join());
        // return _parseNASFileItems(response.data.toString());
        if (response.data is! List) {
          throw NASFileException(
              'Bad response type - response is not type of List');
        }
        return (response.data as List)
            .map<NASFileItem>((json) => NASFileItem.fromJson(json))
            .toList();
      } else {
        print(response.data);
        throw NASFileException(
            'Failed to load NASFileItem list - Http code: ${response.statusCode}');
      }
    } catch (err) {
      print('Caught error: $err');
      // closeConnection(client);
      throw NASFileException(
          'Connection to the ${dioClient.options.baseUrl}/folderItems : ${err}');
    }
  }

  Future<FormData> _createFormData(
      File file, String nasFolderPath, FileTypeForSync fileType) async {
    final lastModified = await file.lastModified();
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'dest': nasFolderPath,
      'mtime': lastModified.secondsSinceEpochInt,
      'type': describeEnum(fileType),
    });
  }

  @override
  Stream<UploadFileStatus> sendFiles(List<File> transferringFileList,
      String nasFolderPath, FileTypeForSync fileType) async* {
    //https://github.com/dart-lang/http/blob/master/test/multipart_test.dart

    if (transferringFileList.isEmpty) {
      print('there is no transferring files');
      //vraci  Stream . empty(), listener of the stream get only onDone event
      return; //Stream generator is quit, Stream is not activated, Stream is not sending any items.
    }

    final sc = await _httpSecurityContext;

    _baseOptions.receiveTimeout = 1 * 60 * 60 * 1000;
    final dioClient = Dio(_baseOptions);

    (dioClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      return HttpClient(context: sc);
    };

    for (var file in transferringFileList) {
      /*
      yield UploadFileStatus(uploadingFilePath: file.path,  timestamp: DateTime.now());

      // await Future.delayed(Duration(seconds: 4), () => throw NASFileException('test error'));
      await Future.delayed(Duration(seconds: 4));

      yield UploadFileStatus(uploadingFilePath: file.path,  timestamp: DateTime.now(), uploaded: true);

       */

      yield UploadFileStatus(
          uploadingFilePath: file.path, timestamp: DateTime.now());

      // await Future.delayed(Duration(seconds: 1));

      // /media/nasraid1/shared/public/photos/miron/phonePhotos/2021/
      var uploadFileData;
      try {
        uploadFileData = await _createFormData(file, nasFolderPath, fileType);
      } catch (err) {
        print('Caught error: $err');
        throw NASFileException(
            'Failed to prepare uploading data. The sending file ${file.path}');
      }

      try {
        final response = await dioClient.post(
          '/upload',
          data: uploadFileData,
          cancelToken: _cancelRequestToken,
        );

        if (response.statusCode == 200) {
          yield UploadFileStatus(
              uploadingFilePath: file.path,
              timestamp: DateTime.now(),
              uploaded: true);
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          // throw Exception('Failed to load NASFileItem list');
          final errorJson = response.data;

          print(errorJson);

          throw NASFileException(
              'Failed to send file ${file.path} - Http code: ${response.statusCode} - error: ${errorJson}');
        }
      } catch (err) {
        print('Caught error: $err');
        throw NASFileException(
            'Request to ${dioClient.options.baseUrl}/upload ERROR : ${err}');
      }
    }
  }

/*
  Future<Response> sendFile(String url, File file) async {
  Dio dio = new Dio();
  var len = await file.length();
  var response = await dio.post(url,
      data: file.openRead(),
      options: Options(headers: {
        Headers.contentLengthHeader: len,
      } // set content-length
          ));
  return response;
}
   */

  @override
  void cancelRequest() {
    _cancelRequestToken.cancel();
  }

  @override
  Future<List<String>> listSambaFolders(String baseFolder) async {
    if (baseFolder.trim().isEmpty) {
      print('base folder is not set');
      throw NASFileException(
          'List samba folder error - base folder is not set');
    }

    final sc = await _httpSecurityContext;

    final dioClient = Dio(_baseOptions);

    (dioClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      return HttpClient(context: sc);
    };

    // final bodyToSend = 'path=${folderPath}';
    try {
//or works once
      final response =
          await dioClient.post('/folders', data: {'path': baseFolder});

      if (response.statusCode == 200) {
        // Use the compute function to run parsePhotos in a separate isolate.
        // return compute(_parseNASFileItems, response.data.toString());
        // return _parseNASFileItems(await response.transform(utf8.decoder).join());
        // return _parseNASFileItems(response.data.toString());
        //if data is not List throw Exception
        if (response.data is! List) {
          throw NASFileException(
              'Bad response type - response is not type of List');
        }
        return (response.data as List)
            .map<String>((item) => '${item}')
            .toList();
      } else {
        print(response.data);
        throw NASFileException(
            'Failed get list folders - status code: ${response.statusCode}, status message: ${response.statusMessage}');
      }
    } catch (err) {
      print('Caught error: $err');
      // closeConnection(client);
      throw NASFileException(
          'Connection to the ${dioClient.options.baseUrl}/folders : ${err}');
    }
  }
}
