class NASFileException implements Exception {
  final String message;

  NASFileException(this.message);

  @override
  String toString() {
    return message;
  }
}
