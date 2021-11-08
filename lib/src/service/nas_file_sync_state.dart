import 'dart:io';

import 'package:flutter/material.dart';
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

  bool uploading = false;

  // Stream<UploadFileStatus> uploadedFileStream;
  UploadFileStatus uploadedFileStatus = UploadFileStatus.empty();

  // bool _synchronizing = false;

  List<File> transferringFileList = <File>[]; //for view only
  final List<File> _allTransferringFileList =
      <File>[]; // in memory the same all time

  int get allTransferringFilesCount => _allTransferringFileList.length;

  int transferredFilesCount = 0;

  List<File> get filesForUploading => List.of(_allTransferringFileList);

  Stream<UploadFileStatus> syncFolderWithNAS(List<File> uploadingFiles,
      String nasFolderPath, FileTypeForSync fileType) async* {
    if (uploading) {
      _log.i('Synchronization is already running!');
      // throw NASFileException('Synchronization is already running!');
      return;
    }

    uploading = true;
    // transferredFilesCount = 0;

    try {
      await for (UploadFileStatus sentFile in _remoteFileTransferService
          .sendFiles(uploadingFiles, nasFolderPath, fileType)) {
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
    } catch (err) {
      _log.e('Caught error:', err);
      throw NASFileException('Error: ${err}');
    } finally {
      _log.i('uploading finished');
      uploading = false;
      uploadedFileStatus = UploadFileStatus(
          uploadingFilePath: '', uploaded: false, timestamp: DateTime.now());
      yield uploadedFileStatus;
    }
    // _synchronizing = false;
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

    // throw NASFileException("message test");
    final allTargetFolderFiles =
        await _remoteFileTransferService.retrieveDirectoryItems(
            nasFolderPath,
            dateFrom.secondsSinceEpoch,
            dateTo.secondsSinceEpoch,
            fileTypeForSync);

    final filesForSync = await _localFileSystemService.matchLocalFiles(
        localFolderPath,
        recursive,
        fileTypeForSync,
        dateFrom,
        dateTo,
        allTargetFolderFiles);

    _allTransferringFileList.addAll(filesForSync);
  }

  DateTime _dateToMidnight(DateTime dateTo) {
    return DateUtils.dateOnly(dateTo);
  }

  void clearShowingFiles() {
    _log.i('clear shownig files');
    transferringFileList.clear();
    transferringFileList = List.empty(growable: true);
  }

  void clearFiles() {
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

  void removeFile(String? filePath) {
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
    return await _remoteFileTransferService.listSambaFolders(baseFolder);
  }
}
