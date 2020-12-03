import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:logger/logger.dart';


class NASFileSyncState {

  final _log = Logger(
    printer: PrettyPrinter(),
  );

  final NASFileSyncService _remoteFileTransferService;

  NASFileSyncState(this._remoteFileTransferService);

  bool _synchronizing = false;
  String transferedFile = '';

  void initSync(){
    _synchronizing = false;
  }

  Future<List<NASFileItem>> retrieveRemoteDirectoryItems(String folderPath) async {
    return await _remoteFileTransferService.retrieveDirectoryItems(folderPath);
  }

  Stream<NASFileItem> syncFolderWithNAS(String localFolderPath, String nasFolderPath) async* {
    assert(nasFolderPath != null);
    assert(localFolderPath != null);

    if(_synchronizing){
      _synchronizing = false;
      throw NASFileException('Synchronization is already running!');
    }

    try {
      
      final targetFolderFileList = await retrieveRemoteDirectoryItems(nasFolderPath);
      final fileToTransferList = await getFilesForSynchronization(targetFolderFileList, localFolderPath);

    
      await for (NASFileItem sentFile in _remoteFileTransferService.sendFiles(fileToTransferList, nasFolderPath)) {
        if (_synchronizing) {
          yield sentFile;
        } else {
          _log.i('Synchronization was aborted');
        }
      }
    } catch (e) {
      
      _log.e('Synchronization failed...', e);
    }

    _synchronizing = false;
    
  }

  Future<List<File>> getFilesForSynchronization(List<NASFileItem> allTargetFolderFiles, String localFolder,
      {bool includeUpdatedFiles = false, bool recursive = false}) async {
    assert(allTargetFolderFiles != null);
    assert(localFolder != null);

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
