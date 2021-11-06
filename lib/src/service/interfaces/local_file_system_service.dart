import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';

abstract class LocalFileSystemService {
  Future<List<File>> matchLocalFiles(String localFolderPath, bool recursive, FileTypeForSync fileTypeForSync,
      DateTime dateFrom, DateTime dateTo, List<NASFileItem> remoteFiles);
}
