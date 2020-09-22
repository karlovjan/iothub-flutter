import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:http/http.dart' as http;


class HTTPNASFileSyncService implements NASFileSyncService {

  // A function that converts a response body into a List<Photo>.
  List<NASFileItem> parseNASFileItems(String responseBody) {

    final parsed = jsonDecode(responseBody) as List;

    return parsed.map<NASFileItem>((json) => NASFileItem.fromJson(json)).toList();
  }

  @override
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath) async {

    try {
      var response = await http.post('http://127.0.0.1:5001/folderItems', body: 'path=${folderPath}', headers: {'Content-Type' : 'application/x-www-form-urlencoded'});

      // body='path=${folderPath}', headers={'Content-Type' = 'application/x-www-form-urlencoded'}
      // request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      // request.body = 'key%201=value&key+2=other%2bvalue';


      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.

        // Use the compute function to run parsePhotos in a separate isolate.
        // TODO return compute(parseNASFileItems, response.body);
        return parseNASFileItems(response.body);
        // return Album.fromJson(json.decode(response.body));
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Failed to load NASFileItem list');
        print(response.body);
      }
    } catch (err){
      print('Caught error: $err');
    }


    var testResult = List<NASFileItem>.empty(growable: true);
    testResult.add(NASFileItem('fileName', 123456));
    // return testResult;
    return await Future.sync(() => testResult);
  }

  @override
  Future<void> syncFolderWithNAS(String localFolderPath, String nasFolderPath) {
    // TODO: implement syncFolderWithNAS
    throw UnimplementedError();
  }



}