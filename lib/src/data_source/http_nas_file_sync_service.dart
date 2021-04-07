import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:iothub/src/data_source/http_dio_nas_file_sync_service.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';

class HTTPNASFileSyncService implements NASFileSyncService {
  HTTPNASFileSyncService(String serverName) : _serverName = serverName;

  final String _serverName;
  SecurityContext _securityContext;

  /// A function that converts a response body into a List<NASFileItem>.
  List<NASFileItem> _parseNASFileItems(String responseBody) {
    final parsed = jsonDecode(responseBody) as List;

    return parsed.map<NASFileItem>((json) => NASFileItem.fromJson(json)).toList();
  }

  //https://en.wikipedia.org/wiki/Cross-site_request_forgery
  //https://dev.to/matheusguimaraes/fast-way-to-enable-cors-in-flask-servers-42p0

  @override
  Future<List<NASFileItem>> retrieveDirectoryItems(
      String folderPath, double dateFromSeconds, double dateToSeconds, FileTypeForSync fileTypeForSync) async {
    if (folderPath == null) {
      print('folder is not set');
      throw NASFileException('Empty folder path');
    }

    final sc = await get_security_Context;

    final client = HttpClient(context: sc);

    // final requestUrl = Uri.http('nas.local:8443', '/folderItems');
    final requestUrl = Uri.https(_serverName, '/folderItems');

    final bodyToSend = 'path=${folderPath}';
    try {
      await client.postUrl(requestUrl).then((HttpClientRequest request) {
        request.write(bodyToSend);

        return request.close();
      }).then((HttpClientResponse response) async {
        // var response = await http.post(requestUrl, body: {'path': folderPath});

        // body='path=${folderPath}', headers={'Content-Type' = 'application/x-www-form-urlencoded'}
        // request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
        // request.body = 'key%201=value&key+2=other%2bvalue';

        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.

          // Use the compute function to run parsePhotos in a separate isolate.
          return compute(_parseNASFileItems, await response.transform(utf8.decoder).join());
          // return _parseNASFileItems(await response.transform(utf8.decoder).join());
          // return Album.fromJson(json.decode(response.body));
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          // throw Exception('Failed to load NASFileItem list');
          print(await response.transform(utf8.decoder).join());
          throw NASFileException('Failed to load NASFileItem list - Http code: ${response.statusCode}');
        }
      });
    } catch (err) {
      print('Caught error: $err');
      throw NASFileException('Connection to the ${requestUrl} : ${err}');
    }
  }

  @override
  Stream<UploadFileStatus> sendFiles(
      List<File> transferringFileList, String nasFolderPath, FileTypeForSync fileType) async* {
    assert(transferringFileList != null);
    assert(nasFolderPath != null);

    //https://github.com/dart-lang/http/blob/master/test/multipart_test.dart

    if (transferringFileList.isEmpty) {
      print('there is no transferring files');
      //vraci  Stream . empty(), listener of the stream get only onDone event
      return; //Stream generator is quit, Stream is not activated, Stream is not sending any items.
    }

    final requestUrl = Uri.https(_serverName, '/upload');
    final client = http.Client();
    try {
      transferringFileList.forEach((file) async* {
        final multipartFile = await http.MultipartFile.fromPath('file', transferringFileList.first.path);

        var request = http.MultipartRequest('POST', requestUrl)
          ..fields['dest'] = nasFolderPath
          ..files.add(multipartFile);

        var response;
        try {
          response = await client.send(request);
        } catch (err) {
          print('Caught error: $err');
          throw NASFileException('Empty folder path');
        }

        if (response.statusCode == 200) {
          yield UploadFileStatus(uploadingFilePath: file.path, timestamp: DateTime.now(), uploaded: true);
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          // throw Exception('Failed to load NASFileItem list');
          final errorJson = await response.stream.bytesToString();

          print(errorJson);

          throw NASFileException(
              'Failed to send file ${file.path} - Http code: ${response.statusCode} - error: ${errorJson}');
        }
      });
    } finally {
      client.close();
    }
  }

  @override
  void cancelRequest() {
    // TODO: implement cancelRequest
  }

  @override
  Future<List<String>> listSambaFolders(String baseFolder) {
    throw UnimplementedError();
  }
}
