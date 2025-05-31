class ProException implements Exception {
  final String message;
  final int? code;
  ProException(this.message, [this.code]);
  @override
  String toString() =>
      '$runtimeType:$message ${code != null ? ("code $code") : ""}';
}

class ProUnknownException extends ProException {
  ProUnknownException(String? message)
    : super(message ?? "unknown errir occured");
}

class ProApiException extends ProException {
  ProApiException(super.message, [super.code]);
}

class ProNetworkApi extends ProException {
  ProNetworkApi(super.message, [super.code]);
}

class ProductParseException extends ProException {
  ProductParseException(super.message, [super.code]);
}

class ProTimeoutException extends ProException {
  final int attempt;
  final int maxAttempt;
  ProTimeoutException({required this.attempt, required this.maxAttempt})
    : super(
        "requested time out after the $attempt  /$maxAttempt attempts have been made",
      );
}
