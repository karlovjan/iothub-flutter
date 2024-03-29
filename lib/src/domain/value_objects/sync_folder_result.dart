import 'package:flutter/foundation.dart';

@immutable
class SyncFolderResult {
  final String? sourceFolderPath;
  final String? targetFolderPath;
  final int? transferredFileCount;
  final int? transferredBytes;

  const SyncFolderResult({this.sourceFolderPath, this.targetFolderPath,
      this.transferredFileCount, this.transferredBytes});
}