import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/sync_folder_result.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';

class NASFileSyncState {
  final NASFileSyncService _fileSyncService;

  NASFileSyncState(this._fileSyncService);

  Future<List<NASFileItem>> retrieveDirectoryItems(String folderPath) async {
    return await _fileSyncService.retrieveDirectoryItems(folderPath);
  }

  Future<SyncFolderResult> syncFolderWithNAS(String localFolderPath, String nasFolderPath) async {
    return await _fileSyncService.syncFolderWithNAS(localFolderPath, nasFolderPath);
  }

  Future<List<File>> getFilesForSynchronization(List<NASFileItem> allTargetFolderFiles, String localFolder,
      {bool includeUpdatedFiles = false, bool recursive = false}) async {
    assert(allTargetFolderFiles != null);
    assert(localFolder != null);
    assert(allTargetFolderFiles.isNotEmpty);

    final localDir = Directory(localFolder);

    final entityList = localDir.list(recursive: true, followLinks: false);

    final resultFiles = <File>[];

    final streamWithoutErrors = entityList.handleError(_onListingFileError);

    await for (FileSystemEntity entity in streamWithoutErrors) {
      var fileType = await FileSystemEntity.type(entity.path);
      if (!recursive && fileType == FileSystemEntityType.file) {
        if (!_isFileInNasList(entity.path, allTargetFolderFiles)) {
          resultFiles.add(File(entity.path));
        }
      }
      //TODO implemnts recurcive and file updated
    }

    return resultFiles;
  }

  void _onListingFileError(Object error, StackTrace stackTrace) {
    print('Caught error: $error');
  }
}

bool _isFileInNasList(String filePath, List<NASFileItem> nasFiles) {
  return nasFiles
      .firstWhere((element) => filePath.endsWith(element.fileName), orElse: () => NASFileItem('', null))
      .fileName
      .isNotEmpty;
}
