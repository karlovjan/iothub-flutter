import 'dart:io';

import 'package:iothub/src/domain/value_objects/upload_file_status.dart';
import 'package:iothub/src/service/common/datetime_ext.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:iothub/src/service/interfaces/local_file_system_service.dart';
import 'package:iothub/src/service/interfaces/nas_file_sync_service.dart';
import 'package:logger/logger.dart';

enum FileTypeForSync { image, video, doc }

class NASFileSyncState {
  NASFileSyncState(
      this._remoteFileTransferService, this._localFileSystemService);

  final _log = Logger(
    printer: PrettyPrinter(),
  );

  final NASFileSyncService _remoteFileTransferService;
  final LocalFileSystemService _localFileSystemService;

  static const BASE_SAMBA_FOLDER = 'photos/miron';

  UploadFileStatus _uploadingFileStatus = UploadFileStatus.empty();

  UploadFileStatus get uploadingFileStatus => _uploadingFileStatus;

  List<File> transferringFileList = <File>[]; //for view only
  final List<File> _allTransferringFileList =
      <File>[]; //in memory the same all time

  int get allTransferringFilesCount => _allTransferringFileList.length;

  int transferredFilesCount = 0;

  bool uploading = false;
  bool _showFiles = false;

  List<File> get filesForUploading => List.of(_allTransferringFileList);

  Stream<void> syncFolderWithNAS(List<File> uploadingFiles,
      String nasFolderPath, FileTypeForSync fileType) async* {
    _log.d('Start uploading files...');
    if (uploadingFiles.isEmpty) {
      _log.i('uploading finished');
      _uploadingFileStatus = UploadFileStatus.empty();
      yield null;
    }

    uploading = true;

    try {
      await for (UploadFileStatus sentFile in _remoteFileTransferService
          .sendFiles(uploadingFiles, nasFolderPath, fileType)) {
        if (sentFile.uploaded) {
          _fileUploaded(sentFile);
        } else {
          //whatching only uploading file
          _uploadingFileStatus = sentFile;
          yield null;
        }
      }
    } catch (err) {
      _log.e('Caught error:', err);
      throw NASFileException('Error: $err');
    } finally {
      _log.i('uploading finished');
      _uploadingFileStatus = UploadFileStatus.empty();
      uploading = false;
      yield null;
    }
  }

  Future<void> getFilesForSynchronization(
      String localFolderPath,
      String nasFolderPath,
      FileTypeForSync fileTypeForSync,
      DateTime dateFrom,
      DateTime dateTo,
      {bool includeUpdatedFiles = false,
      bool recursive = false}) async {
    _log.i('Load files for synchronization');

    clearFiles();

    DateTime dateToMidnight =
        DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59, 0, 0);

    // throw NASFileException("message test");
    final allTargetFolderFiles =
        await _remoteFileTransferService.retrieveDirectoryItems(
            nasFolderPath,
            dateFrom.secondsSinceEpoch,
            dateToMidnight.secondsSinceEpoch,
            fileTypeForSync);

    final filesForSync = await _localFileSystemService.matchLocalFiles(
        localFolderPath,
        recursive,
        fileTypeForSync,
        dateFrom,
        dateToMidnight,
        allTargetFolderFiles);

    _log.d('files for uploading is ${filesForSync.length}');

    _allTransferringFileList.addAll(filesForSync);
  }

  void clearShowingFiles() {
    _log.i('clear showing files');
    _showFiles = false;
    transferringFileList = <File>[];
  }

  void clearFiles() {
    _log.i('clear files');
    _allTransferringFileList.clear();
    transferringFileList = List.empty();
    transferredFilesCount = 0;
  }

  void cancelUploading() {
    _log.i('cancel upload request');

    try {
      _remoteFileTransferService.cancelRequest();
    } catch (err) {
      _log.e('Canceling of uploading files failed:', err);
    } finally {
      _uploadingFileStatus = UploadFileStatus.empty();
      uploading = false;
    }
  }

  void _fileUploaded(UploadFileStatus status) {
    removeFile(status.uploadingFilePath);
    ++transferredFilesCount;
  }

  void removeFile(String filePath) {
    _log.d('remove file $filePath');
    final removingFile = _allTransferringFileList.firstWhere(
      (element) => element.path == filePath,
      orElse: () => File(''),
    );
    //was item found
    if (removingFile.path.isNotEmpty) {
      _allTransferringFileList.remove(removingFile);

      _showFirstFilesInternal();
    }
  }

  void _showFirstFilesInternal([int filesCount = 20]) {
    if (_showFiles) {
      _log.d('show first $filesCount files - internal...');
      final fileListLength = allTransferringFilesCount;
      final endIndex =
          filesCount <= fileListLength ? filesCount : fileListLength;
      transferringFileList = _allTransferringFileList.sublist(0, endIndex);
    }
  }

  void showFirstFiles([int filesCount = 20]) {
    _log.d('show first $filesCount files...');
    _showFiles = true;
    _showFirstFilesInternal(filesCount);
  }

  Future<List<String>> listSambaFolders(String baseFolder) async {
    return await _remoteFileTransferService.listSambaFolders(baseFolder);
  }
}
