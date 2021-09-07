// Mocks generated by Mockito 5.0.14 from annotations
// in iothub/test/pages/nas/nas_sync_page_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;
import 'dart:io' as _i7;

import 'package:iothub/src/domain/entities/nas_file_item.dart' as _i4;
import 'package:iothub/src/domain/value_objects/upload_file_status.dart' as _i6;
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart'
    as _i2;
import 'package:iothub/src/service/nas_file_sync_state.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

/// A class which mocks [NASFileSyncService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNASFileSyncService extends _i1.Mock
    implements _i2.NASFileSyncService {
  MockNASFileSyncService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.NASFileItem>> retrieveDirectoryItems(
          String? folderPath,
          double? dateFromSeconds,
          double? dateToSeconds,
          _i5.FileTypeForSync? fileTypeForSync) =>
      (super.noSuchMethod(
              Invocation.method(#retrieveDirectoryItems, [
                folderPath,
                dateFromSeconds,
                dateToSeconds,
                fileTypeForSync
              ]),
              returnValue:
                  Future<List<_i4.NASFileItem>>.value(<_i4.NASFileItem>[]))
          as _i3.Future<List<_i4.NASFileItem>>);
  @override
  _i3.Stream<_i6.UploadFileStatus> sendFiles(
          List<_i7.File>? transferringFileList,
          String? nasFolderPath,
          _i5.FileTypeForSync? fileTypeForSync) =>
      (super.noSuchMethod(
              Invocation.method(#sendFiles,
                  [transferringFileList, nasFolderPath, fileTypeForSync]),
              returnValue: Stream<_i6.UploadFileStatus>.empty())
          as _i3.Stream<_i6.UploadFileStatus>);
  @override
  void cancelRequest() =>
      super.noSuchMethod(Invocation.method(#cancelRequest, []),
          returnValueForMissingStub: null);
  @override
  _i3.Future<List<String>> listSambaFolders(String? baseFolder) =>
      (super.noSuchMethod(Invocation.method(#listSambaFolders, [baseFolder]),
              returnValue: Future<List<String>>.value(<String>[]))
          as _i3.Future<List<String>>);
  @override
  String toString() => super.toString();
}
