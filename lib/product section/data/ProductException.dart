abstract class ProductException implements Exception {
  final String message;
  final int? code;
  ProductException(this.message, [this.code]);

  @override
  String toString() =>
      '$runtimeType:$message ${code != null ? '(Code $code)' : ""}';
}

class ProductUnknownException extends ProductException {
  ProductUnknownException([String? message])
    : super(message ?? 'Unknown error occurred');
}

class ProductApiException extends ProductException {
  ProductApiException(super.message, [super.code]);
}

class ProductNetworkException extends ProductException {
  ProductNetworkException(super.message, [super.code]);
}

class ProductParseException extends ProductException {
  ProductParseException(super.message, [super.code]);
}

class ProductTimeoutException extends ProductException {
  final int attempt;
  final int maxAttempt;
  ProductTimeoutException({required this.attempt, required this.maxAttempt})
    : super("requested time out after the $attempt /$maxAttempt attempts");
}
