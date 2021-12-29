import 'package:flutter/foundation.dart';

@immutable
class UploadFileStatus {
  final String uploadingFilePath;
  final DateTime timestamp;
  final bool uploaded;

  const UploadFileStatus({required this.uploadingFilePath, required this.timestamp, this.uploaded = false});

  static UploadFileStatus copyOf(UploadFileStatus newStatus) {
    return UploadFileStatus(
        uploadingFilePath: newStatus.uploadingFilePath,
        timestamp: newStatus.timestamp,
        uploaded: newStatus.uploaded);
  }

  factory UploadFileStatus.empty() {
    return UploadFileStatus(uploadingFilePath: '', timestamp: DateTime.now(), uploaded: false);
  }
}
