class DatabaseException extends Error {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() {
    return message.toString();
  }
}
