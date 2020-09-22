class NASFileItem {
  final String fileName;
  final double lastModified;
  // DateTime lastModified;

  NASFileItem(this.fileName, this.lastModified);

  factory NASFileItem.fromJson(dynamic json) {
    return NASFileItem(
      json['name'] as String,
      json['mtime'] as double,
    );
  }

}