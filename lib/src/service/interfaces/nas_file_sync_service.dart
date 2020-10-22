import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';

abstract class NASFileSyncService {
  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath);

  Stream<NASFileItem> sendFiles(List<File> transferringFileList, String nasFolderPath);
}
