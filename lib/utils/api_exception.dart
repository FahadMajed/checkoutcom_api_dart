class ApiException implements Exception {
  final _message;
  final _prefix;

  ApiException(this._message, this._prefix);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String message)
      : super(message, "Error During Communication: ");
}

class BadGateway extends ApiException {
  BadGateway(String message) : super(message, "Bad Gateway: ");
}

class NotFound extends ApiException {
  NotFound(String message) : super(message, "not found: ");
}

class TooManyRequests extends ApiException {
  TooManyRequests(String message)
      : super(message, "Too many requests or duplicate request detected : ");
}

class BadRequestException extends ApiException {
  BadRequestException(message) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(message) : super(message, "Unauthorized: ");
}

class InvalidRequestException extends ApiException {
  InvalidRequestException(String message) : super(message, "Invalid request: ");
}
