import 'dart:io';

import 'package:iothub/src/domain/entities/nas_file_item.dart';
import 'package:iothub/src/service/interfaces/local_file_system_service.dart';
import 'package:iothub/src/service/nas_file_sync_state.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import 'common/datetime_ext.dart';
import 'exceptions/nas_file_sync_exception.dart';

class LocalFileSystemUtil implements LocalFileSystemService {
  LocalFileSystemUtil();

  final _log = Logger(
    printer: PrettyPrinter(),
  );

  @override
  Future<List<File>> matchLocalFiles(
      String localFolderPath,
      bool recursive,
      FileTypeForSync fileTypeForSync,
      DateTime dateFrom,
      DateTime dateTo,
      List<NASFileItem> allTargetFolderFiles) async {
    final fileList = <File>[];

    final localDir = Directory(localFolderPath);

    final entityList = localDir.list(recursive: true, followLinks: false);

    // final streamWithoutErrors = entityList.handleError(_onListingFileError);

    try {
      await for (FileSystemEntity entity in entityList) {
        final fileType = await FileSystemEntity.type(entity.path);
        if (!recursive &&
            fileType == FileSystemEntityType.file &&
            filterFileByType(entity, fileTypeForSync)) {
          final dateInRange = await isDateInRange(entity, dateFrom, dateTo);
          if (dateInRange) {
            if (!_isFileInNasList(entity.path, allTargetFolderFiles)) {
              fileList.add(File(entity.path));
            }
          }
        }

        //TODO implemnts recurcive and file updated
      }
    } catch (err) {
      _log.e('Caught error:', err);
      throw NASFileException('Error: $err');
    }

    return fileList;
  }

  void _onListingFileError(Object error, StackTrace stackTrace) {
    _log.e('Caught error:', error, stackTrace);
  }

  bool _isFileInNasList(String filePath, List<NASFileItem> nasFiles) {
    return nasFiles
        .firstWhere((nasFile) => filePath.endsWith(nasFile.fileName),
            orElse: () => NASFileItem('', DateTime.now()))
        .fileName
        .isNotEmpty;
  }

  bool filterFileByType(FileSystemEntity entity, FileTypeForSync type) {
    final ext = path.extension(entity.path).toLowerCase();
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

  Future<bool> isDateInRange(
      FileSystemEntity entity, DateTime dateFrom, DateTime dateTo) async {
    final fileStat = await entity.stat();

    var modified = fileStat.modified;

    // final result = modified.isAtSameMomentAs(dateFrom) || (modified.isAfter(dateFrom) && modified.isBefore(dateTo));
    return modified.isBetween(dateFrom, dateTo);
  }
}
