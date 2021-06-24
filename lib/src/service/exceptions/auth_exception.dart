class AuthorizationException extends Error {
  final String message;

  AuthorizationException(this.message);

  @override
  String toString() {
    return message;
  }
}
