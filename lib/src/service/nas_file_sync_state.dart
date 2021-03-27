import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

enum FileTypeForSync { image, video, doc }

class NASFileSyncState {
  final _log = Logger(
    printer: PrettyPrinter(),
  );

  final NASFileSyncService _remoteFileTransferService;

  //TODO make const constructor
  NASFileSyncState(this._remoteFileTransferService);

  // bool _synchronizing = false;

  List<File> transferringFileList = <File>[];

  void initSync() {
    // _synchronizing = false;
  }

  Future<List<NASFileItem>> retrieveRemoteDirectoryItems(String folderPath) async {
    return await _remoteFileTransferService.retrieveDirectoryItems(folderPath);
  }

  Stream<NASFileItem> syncFolderWithNAS(List<NASFileItem> allTargetFolderFiles, String nasFolderPath) async* {
    assert(allTargetFolderFiles != null);
    assert(nasFolderPath != null);

    // if (_synchronizing) {
    //   _synchronizing = false;
    //   throw NASFileException('Synchronization is already running!');
    // }

    await for (NASFileItem sentFile in _remoteFileTransferService.sendFiles(transferringFileList, nasFolderPath)) {
      // if (_synchronizing) {
      yield sentFile;
      // } else {
      //   _log.i('Synchronization was aborted');
      //   throw NASFileException('Synchronization was aborted!');
      // }
    }

    // _synchronizing = false;
  }

  Future<List<File>> getFilesForSynchronization(
      String localFolderPath, String nasFolderPath, FileTypeForSync fileTypeForSync, DateTime dateFrom,
      {bool includeUpdatedFiles = false, bool recursive = false}) async {
    assert(nasFolderPath != null);
    assert(localFolderPath != null);

    // throw NASFileException("message test");
    // final allTargetFolderFiles = await retrieveRemoteDirectoryItems(nasFolderPath);

    final localDir = Directory(localFolderPath);

    final entityList = localDir.list(recursive: true, followLinks: false);

    final resultFiles = <File>[];

    final streamWithoutErrors = entityList.handleError(_onListingFileError);

    await for (FileSystemEntity entity in streamWithoutErrors) {
      final fileType = await FileSystemEntity.type(entity.path);
      final isNewerThan = await isDateNewerThen(entity, dateFrom);
      if (!recursive &&
          fileType == FileSystemEntityType.file &&
          filterFileByType(entity, fileTypeForSync) &&
          isNewerThan) {
        // if (!_isFileInNasList(entity.path, allTargetFolderFiles)) {
        resultFiles.add(File(entity.path));
        // }
      }

      //TODO implemnts recurcive and file updated
    }

    return resultFiles;
  }

  void _onListingFileError(Object error, StackTrace stackTrace) {
    print('Caught error: $error');
  }

  bool _isFileInNasList(String filePath, List<NASFileItem> nasFiles) {
    return nasFiles
        .firstWhere((element) => filePath.endsWith(element.fileName), orElse: () => NASFileItem('', null))
        .fileName
        .isNotEmpty;
  }

  bool filterFileByType(FileSystemEntity entity, FileTypeForSync type) {
    switch (type) {
      case FileTypeForSync.image:
        return ['.jpg', '.JPG'].contains(path.extension(entity.path));
      case FileTypeForSync.video:
        return ['.mp4', '.avi', '.mpeg'].contains(path.extension(entity.path));
      case FileTypeForSync.doc:
        return ['.txt', '.doc', '.pdf'].contains(path.extension(entity.path));
      default:
        throw NASFileException('Unknown file type!');
    }
  }

  void removeFileFromList(File imgFile) {
    transferringFileList.remove(imgFile);
    transferringFileList = List<File>.of(transferringFileList);
  }

  Future<bool> isDateNewerThen(FileSystemEntity entity, [DateTime dateFrom]) async {
    final fileStat = await entity.stat();

    dateFrom ??= DateTime.now().subtract(const Duration(days: 1));

    var modified = fileStat.modified;
    modified ??= fileStat.changed;

    final modifiedDate = DateTime(modified.year, modified.month, modified.day);
    final dataOnlyFrom = (DateTime(dateFrom.year, dateFrom.month, dateFrom.day));

    return modifiedDate.isAtSameMomentAs(dataOnlyFrom) || modifiedDate.isAfter(dataOnlyFrom);
  }
}
