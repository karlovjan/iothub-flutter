class AuthorizationException implements Exception {
  final String message;

  AuthorizationException(this.message);

  @override
  String toString() {
    return message;
  }
}
