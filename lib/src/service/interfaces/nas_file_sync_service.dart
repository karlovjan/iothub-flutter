import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';

abstract class NASFileSyncService {
  Future<List<NASFileItem>> retrieveDirectoryItems(
      String folderPath, double dateFromSeconds, double dateToSeconds, FileTypeForSync fileTypeForSync);

  Stream<UploadFileStatus> sendFiles(
      List<File> transferringFileList, String nasFolderPath, FileTypeForSync fileTypeForSync);

  void cancelRequest();

  Future<List<String>> listSambaFolders(String baseFolder);
}
