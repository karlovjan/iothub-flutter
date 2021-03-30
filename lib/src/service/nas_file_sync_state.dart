import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/common/datetime_ext.dart';
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

  bool uploading = false;

  // Stream<UploadFileStatus> uploadedFileStream;
  UploadFileStatus uploadedFileStatus =
      UploadFileStatus(uploadingFilePath: '', timestamp: DateTime.now(), uploaded: false);

  //TODO make const constructor
  NASFileSyncState(this._remoteFileTransferService);

  // bool _synchronizing = false;

  List<File> transferringFileList = <File>[]; //for view only
  final List<File> _allTransferringFileList = <File>[]; // in memory the same all time

  int get allTransferringFilesCount => _allTransferringFileList.length;

  int transferredFilesCount = 0;

  Future<List<NASFileItem>> retrieveRemoteDirectoryItems(String folderPath) async {
    return await _remoteFileTransferService.retrieveDirectoryItems(folderPath);
  }

  Stream<UploadFileStatus> syncFolderWithNAS(List<File> allTargetFolderFiles, String nasFolderPath) async* {
    assert(allTargetFolderFiles != null);
    assert(nasFolderPath != null);

    if (uploading) {
      print('Synchronization is already running!');
      // throw NASFileException('Synchronization is already running!');
      return;
    }

    uploading = true;
    transferredFilesCount = 0;

    try {
      await for (UploadFileStatus sentFile
          in _remoteFileTransferService.sendFiles(List<File>.of(transferringFileList), nasFolderPath)) {
        // if (_synchronizing) {

        if (sentFile.uploaded) {
          _fileUploaded(sentFile);
        } else {
          //whatching only uploading file
          uploadedFileStatus = sentFile;
        }
        yield sentFile;
        // } else {
        //   _log.i('Synchronization was aborted');
        //   throw NASFileException('Synchronization was aborted!');
        // }
      }
    } finally {
      uploading = false;
      uploadedFileStatus = UploadFileStatus(uploadingFilePath: '', uploaded: false, timestamp: DateTime.now());
    }
    // _synchronizing = false;
  }

  Future<void> getFilesForSynchronization(
      String localFolderPath, String nasFolderPath, FileTypeForSync fileTypeForSync, DateTime dateFrom, DateTime dateTo,
      {bool includeUpdatedFiles = false, bool recursive = false}) async {
    assert(nasFolderPath != null);
    assert(localFolderPath != null);
    assert(dateFrom != null);
    assert(dateTo != null);

    transferredFilesCount = 0;
    _allTransferringFileList.clear();
    // throw NASFileException("message test");
    // final allTargetFolderFiles = await retrieveRemoteDirectoryItems(nasFolderPath);

    final localDir = Directory(localFolderPath);

    final entityList = localDir.list(recursive: true, followLinks: false);

    final streamWithoutErrors = entityList.handleError(_onListingFileError);

    await for (FileSystemEntity entity in streamWithoutErrors) {
      final fileType = await FileSystemEntity.type(entity.path);
      if (!recursive &&
          fileType == FileSystemEntityType.file &&
          filterFileByType(entity, fileTypeForSync)) {
        final dateInRange = await isDateInRange(entity, dateFrom, dateTo);
        if(dateInRange) {
          // if (!_isFileInNasList(entity.path, allTargetFolderFiles)) {
          _allTransferringFileList.add(File(entity.path));
          // }
        }
      }

      //TODO implemnts recurcive and file updated
    }

    return;
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

  Future<bool> isDateInRange(FileSystemEntity entity, DateTime dateFrom, DateTime dateTo) async {
    final fileStat = await entity.stat();

    dateFrom ??= DateTime.now().dateNow();
    dateTo ??= DateTime.now();

    var modified = fileStat.modified;
    modified ??= fileStat.changed;

    // final result = modified.isAtSameMomentAs(dateFrom) || (modified.isAfter(dateFrom) && modified.isBefore(dateTo));
    return modified.isBetween(dateFrom, dateTo);
  }

  void clearFileList() {
    _allTransferringFileList.clear();
    transferringFileList.clear();
    transferredFilesCount = 0;
  }

  void cancelUploading() {
    uploading = false;
    _remoteFileTransferService.cancelRequest();
  }

  void _fileUploaded(UploadFileStatus status) {
    removeFile(status.uploadingFilePath);
    ++transferredFilesCount;
  }

  void removeFile(String filePath) {
    // var newList = List<File>.of(transferringFileList);
    // newList.removeWhere((e) => e.path == filePath);
    final removingFile = transferringFileList.firstWhere(
      (element) => element.path == filePath,
      orElse: () => File(''),
    );
    //was item found
    if (removingFile.path.isNotEmpty) {
      var newList = List<File>.of(transferringFileList);
      _allTransferringFileList.remove(removingFile);
      newList.remove(removingFile);
      transferringFileList = newList;
    }
  }

  void showNextFiles([int filesCount = 20]) {
    final fileListLength = allTransferringFilesCount;
    final endIndex = filesCount <= fileListLength ? filesCount : fileListLength;
    transferringFileList = _allTransferringFileList.sublist(0, endIndex);
  }
}
