import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';

abstract class NASFileSyncService {
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath);

  Stream<UploadFileStatus> sendFiles(List<File> transferringFileList, String nasFolderPath);

  void cancelRequest() {}
}
