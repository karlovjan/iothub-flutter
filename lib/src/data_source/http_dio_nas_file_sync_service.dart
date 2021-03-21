import 'dart:io';
import 'dart:typed_data';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';

SecurityContext httpSecurityContext;

Future<ByteData> loadCACert() async {
//public certificate of CA
  return await rootBundle.load('assets/certs/ca.crt');
}

Future<ByteData> loadPKCS12() async {
//client a kew and certificate package
// return await rootBundle.load('assets/certs/iothubclient.p12');
  return await rootBundle.load('assets/certs/smbresthomeclient.p12');
}

Future<SecurityContext> createSecurityContext() async {
// final sc = SecurityContext(withTrustedRoots: true);
  final sc = SecurityContext.defaultContext;

  try {
    final cacertBytes = await loadCACert();
    sc.setTrustedCertificatesBytes(cacertBytes.buffer.asUint8List());

    final p12 = await loadPKCS12();
    sc.usePrivateKeyBytes(p12.buffer.asUint8List());
    sc.useCertificateChainBytes(p12.buffer.asUint8List());
  } catch (err) {
    print('Caught error: $err');
    throw NASFileException('load certificates error: ${err}');
  }

  return sc;
}

Future<SecurityContext> get get_security_Context async {
  return httpSecurityContext ??= await createSecurityContext();
}

class DIOHTTPNASFileSyncService implements NASFileSyncService {
  DIOHTTPNASFileSyncService(String serverName) : _serverName = serverName;

  final String _serverName;

  //https://en.wikipedia.org/wiki/Cross-site_request_forgery
  //https://dev.to/matheusguimaraes/fast-way-to-enable-cors-in-flask-servers-42p0

  @override
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath) async {
    if (folderPath == null) {
      print('folder is not set');
      throw NASFileException('Empty folder path');
    }

    final sc = await get_security_Context;

    final client = Dio();

    // (client.transformer as DefaultTransformer).jsonDecodeCallback = _parseJsonInIsolation;

    // final requestUrl = Uri.http('nas.local:8443', '/folderItems');
    final requestUrl = Uri.https(_serverName, '/folderItems');

    // final bodyToSend = 'path=${folderPath}';
    try {
      //Instance level
      client.options.contentType = Headers.formUrlEncodedContentType;
      client.options.responseType = ResponseType.json;

      (client.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        final httpClient = HttpClient(context: sc);
        httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
          if (host == _serverName) {
            // Verify the certificate
            return true; // allow self-signed certificate in development only!!!
          }
          print('Bad certification for host ${host} and port ${port}');
          return false;
        };
        return httpClient;
      };

//or works once
      final response = await client.postUri(requestUrl, data: {'path': folderPath});

      if (response.statusCode == 200) {
        // Use the compute function to run parsePhotos in a separate isolate.
        // return compute(_parseNASFileItems, response.data.toString());
        // return _parseNASFileItems(await response.transform(utf8.decoder).join());
        // return _parseNASFileItems(response.data.toString());
        return (response.data as List).map<NASFileItem>((json) => NASFileItem.fromJson(json)).toList();
      } else {
        print(response.data);
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