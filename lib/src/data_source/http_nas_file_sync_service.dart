import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';

class HTTPNASFileSyncService implements NASFileSyncService {
  /// A function that converts a response body into a List<NASFileItem>.
  List<NASFileItem> _parseNASFileItems(String responseBody) {
    final parsed = jsonDecode(responseBody) as List;

    return parsed.map<NASFileItem>((json) => NASFileItem.fromJson(json)).toList();
  }

  //https://en.wikipedia.org/wiki/Cross-site_request_forgery
  //https://dev.to/matheusguimaraes/fast-way-to-enable-cors-in-flask-servers-42p0

  @override
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath) async {
    if (folderPath == null) {
      print('folder is not set');
      throw NASFileException('Empty folder path');
    }

    final requestUrl = Uri.http('127.0.0.1:5001', '/folderItems'); // 'http://127.0.0.1:5001/folderItems';

    // final bodyToSend = 'path=${folderPath}';
    try {
      var response = await http.post(requestUrl, body: {'path': folderPath});

      // body='path=${folderPath}', headers={'Content-Type' = 'application/x-www-form-urlencoded'}
      // request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      // request.body = 'key%201=value&key+2=other%2bvalue';

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.

        // Use the compute function to run parsePhotos in a separate isolate.
        return compute(_parseNASFileItems, response.body);
        // return _parseNASFileItems(response.body);
        // return Album.fromJson(json.decode(response.body));
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Failed to load NASFileItem list');
        print(response.body);
        throw NASFileException('Failed to load NASFileItem list - Http code: ${response.statusCode}');
      }
    } catch (err) {
      print('Caught error: $err');
      throw NASFileException('Connection to the ${requestUrl} : ${err}');
    }
  }

  @override
  Stream<NASFileItem> sendFiles(List<File> transferringFileList, String nasFolderPath) async* {
    assert(transferringFileList != null);
    assert(nasFolderPath != null);

    //https://github.com/dart-lang/http/blob/master/test/multipart_test.dart

    if (transferringFileList.isEmpty) {
      print('there is no transferring files');
      //vraci  Stream . empty(), listener of the stream get only onDone event
      return; //Stream generator is quit, Stream is not activated, Stream is not sending any items.
    }

    final client = http.Client();
    try {
      transferringFileList.forEach((file) async* {
        final multipartFile = await http.MultipartFile.fromPath('file', transferringFileList.first.path);

        var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:5001/upload'))
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
          yield NASFileItem(file.path, DateTime.now());
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
}
