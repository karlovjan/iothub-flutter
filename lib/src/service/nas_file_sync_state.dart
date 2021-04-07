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

  List<String> _sambaFolderList;

  List<File> get filesForUploading => List.of(_allTransferringFileList);

  Stream<UploadFileStatus> syncFolderWithNAS(
      List<File> uploadingFiles, String nasFolderPath, FileTypeForSync fileType) async* {
    assert(uploadingFiles != null);
    assert(nasFolderPath != null);
    assert(fileType != null);

    if (uploading) {
      _log.i('Synchronization is already running!');
      // throw NASFileException('Synchronization is already running!');
      return;
    }

    uploading = true;
    // transferredFilesCount = 0;

    try {
      await for (UploadFileStatus sentFile
          in _remoteFileTransferService.sendFiles(uploadingFiles, nasFolderPath, fileType)) {
        // if (_synchronizing) {

        if (sentFile.uploaded) {
          _fileUploaded(sentFile);
        } else {
          //whatching only uploading file
          uploadedFileStatus = sentFile;
          yield sentFile;
        }

        // } else {
        //   _log.i('Synchronization was aborted');
        //   throw NASFileException('Synchronization was aborted!');
        // }
      }
    } finally {
      _log.i('uploading finished');
      uploading = false;
      uploadedFileStatus = UploadFileStatus(uploadingFilePath: '', uploaded: false, timestamp: DateTime.now());
      yield uploadedFileStatus;
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
    assert(fileTypeForSync != null);

    _log.i('Load files for synchronization');

    clearFileList();
    // throw NASFileException("message test");
    final allTargetFolderFiles = await _remoteFileTransferService.retrieveDirectoryItems(
        nasFolderPath, dateFrom.secondsSinceEpoch, _dateToMidnight(dateTo).secondsSinceEpoch, fileTypeForSync);

    final localDir = Directory(localFolderPath);

    final entityList = localDir.list(recursive: true, followLinks: false);

    final streamWithoutErrors = entityList.handleError(_onListingFileError);

    // try {
    await for (FileSystemEntity entity in streamWithoutErrors) {
      final fileType = await FileSystemEntity.type(entity.path);
      if (!recursive && fileType == FileSystemEntityType.file && filterFileByType(entity, fileTypeForSync)) {
        final dateInRange = await isDateInRange(entity, dateFrom, dateTo);
        if (dateInRange) {
          if (!_isFileInNasList(entity.path, allTargetFolderFiles)) {
            _allTransferringFileList.add(File(entity.path));
          }
        }
      }

      //TODO implemnts recurcive and file updated
    }
    // } catch (err) {
    //   throw NASFileException('Error: ${err}');
    // }
  }

  void _onListingFileError(Object error, StackTrace stackTrace) {
    _log.e('Caught error:', error, stackTrace);
  }

  bool _isFileInNasList(String filePath, List<NASFileItem> nasFiles) {
    return nasFiles
        .firstWhere((nasFile) => filePath.endsWith(nasFile.fileName), orElse: () => NASFileItem('', null))
        .fileName
        .isNotEmpty;
  }

  bool filterFileByType(FileSystemEntity entity, FileTypeForSync type) {
    final ext = path.extension(entity.path)?.toLowerCase();
    switch (type) {
      case FileTypeForSync.image:
        return ['.jpg', '.jpeg', '.gif', '.png', '.dng'].contains(ext);
      case FileTypeForSync.video:
        return ['.mp4', '.avi', '.mkv'].contains(ext);
      case FileTypeForSync.doc:
        return ['.txt', '.pdf', '.docx', '.odt', '.doc'].contains(ext);
      default:
        throw NASFileException('Unknown file type!');
    }
  }

  Future<bool> isDateInRange(FileSystemEntity entity, DateTime dateFrom, DateTime dateTo) async {
    final fileStat = await entity.stat();

    dateFrom ??= DateTime.now().dateNow();
    dateTo = _dateToMidnight(dateTo); //aby datum byl az do konce aktualniho dne, exclude date to

    var modified = fileStat.modified;
    modified ??= fileStat.changed;

    // final result = modified.isAtSameMomentAs(dateFrom) || (modified.isAfter(dateFrom) && modified.isBefore(dateTo));
    return modified.isBetween(dateFrom, dateTo);
  }

  DateTime _dateToMidnight(DateTime dateTo) {
    dateTo ??= DateTime.now().dateNow();

    dateTo.add(Duration(days: 1)).dateNow(); //aby datum byl az do konce aktualniho dne, exclude date to
    return dateTo;
  }

  void clearFileList() {
    _log.i('clear files');
    _allTransferringFileList.clear();
    transferringFileList.clear();
    transferringFileList = List.empty(growable: true);
    transferredFilesCount = 0;
  }

  void cancelUploading() {
    _log.i('cancel upload request');
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
    final removingFile = _allTransferringFileList.firstWhere(
      (element) => element.path == filePath,
      orElse: () => File(''),
    );
    //was item found
    if (removingFile.path.isNotEmpty) {
      _allTransferringFileList.remove(removingFile);

      showFirstFiles();
    }
  }

  void showFirstFiles([int filesCount = 20]) {
    final fileListLength = allTransferringFilesCount;
    final endIndex = filesCount <= fileListLength ? filesCount : fileListLength;
    transferringFileList = _allTransferringFileList.sublist(0, endIndex);
  }

  Future<List<String>> listSambaFolders(String baseFolder) async {
    return _sambaFolderList ??= await _remoteFileTransferService.listSambaFolders(baseFolder);
  }
}
