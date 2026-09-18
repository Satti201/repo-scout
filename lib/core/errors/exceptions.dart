class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;

  const ServerException(this.message);

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException(this.message);

  @override
  String toString() => message;
}

class RateLimitException implements Exception {
  final String message;

  const RateLimitException(this.message);

  @override
  String toString() => message;
}

class ParsingException implements Exception {
  final String message;

  const ParsingException(this.message);

  @override
  String toString() => message;
}
