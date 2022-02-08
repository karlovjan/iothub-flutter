import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../service/nas_file_sync_state.dart';

// @immutable
class SyncFormData {
  String name;
  String localFolder;
  String remoteFolder;
  DateTime from;
  DateTime to;
  FileTypeForSync fileType;

  SyncFormData(this.name,
      this.localFolder, this.remoteFolder, this.from, this.to, this.fileType);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncFormData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          localFolder == other.localFolder &&
          remoteFolder == other.remoteFolder &&
          from == other.from &&
          to == other.to &&
          fileType == other.fileType;

  @override
  int get hashCode =>
      name.hashCode ^
      localFolder.hashCode ^
      remoteFolder.hashCode ^
      from.hashCode ^
      to.hashCode ^
      fileType.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'localFolder': localFolder,
      'remoteFolder': remoteFolder,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'fileType': describeEnum(fileType),
    };
  }

  factory SyncFormData.fromMap(Map<String, dynamic> map) {
    return SyncFormData(
      map['name'],
      map['localFolder'],
      map['remoteFolder'],
      DateTime.parse(map['from']),
      DateTime.parse(map['to']),
      FileTypeForSync.values.firstWhere(
        (e) => e.toString() == 'FileTypeForSync.' + map['fileType'],
        orElse: () => FileTypeForSync.image,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncFormData.fromJson(String source) =>
      SyncFormData.fromMap(json.decode(source));
}
