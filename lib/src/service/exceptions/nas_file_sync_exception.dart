class NASFileException extends Error {
  final String message;

  NASFileException(this.message);

  @override
  String toString() {
    return message;
  }
}
