class NASFileItem {
  final String fileName;
  final DateTime lastModified;

  NASFileItem(this.fileName, this.lastModified);

  factory NASFileItem.fromJson(dynamic json) {
    return NASFileItem(
      json['name'] as String,
      DateTime.parse(json['mtime'] as String),
    );
  }
}
