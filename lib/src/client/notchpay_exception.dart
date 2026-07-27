/// Base class for every error thrown by this package.
sealed class NotchPayException implements Exception {
  const NotchPayException(this.message);

  /// Human readable explanation of what went wrong.
  final String message;

  @override
  String toString() => 'NotchPayException: $message';
}

/// Thrown when the SDK is used incorrectly (e.g. missing configuration).
class NotchPayConfigurationException extends NotchPayException {
  /// Creates a configuration error with the given [message].
  const NotchPayConfigurationException(super.message);
}

/// Thrown when the device has no usable network connection or the request
/// could not reach the NotchPay servers.
class NotchPayNetworkException extends NotchPayException {
  /// Creates a network error with the given [message] and optional [cause].
  const NotchPayNetworkException(super.message, {this.cause});

  /// The underlying error that triggered this exception, if any.
  final Object? cause;
}

/// Thrown when the NotchPay API responds with an error payload.
///
/// See https://developers.notchpay.co for the meaning of [code].
class NotchPayApiException extends NotchPayException {
  /// Creates an API error from a decoded error response.
  const NotchPayApiException({
    required this.statusCode,
    required String message,
    this.code,
    this.errors,
    this.raw,
  }) : super(message);

  /// The HTTP status code returned by the API.
  final int statusCode;

  /// A machine readable error code, when the API provides one.
  final String? code;

  /// Field level validation errors, when the API provides them.
  final Map<String, dynamic>? errors;

  /// The raw decoded response body, for advanced use cases.
  final Map<String, dynamic>? raw;

  /// Whether this error was caused by an invalid or expired transaction.
  bool get isNotFound => statusCode == 404;

  /// Whether this error is caused by bad or missing authorization keys.
  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  /// Whether this error is a validation error (unprocessable request).
  bool get isValidationError => statusCode == 422;

  /// Whether the API is currently unavailable or returned a server error.
  bool get isServerError => statusCode >= 500;

  @override
  String toString() =>
      'NotchPayApiException($statusCode${code != null ? ', code: $code' : ''}): $message';
}

/// Thrown when a payment could not be completed on the client side, for
/// example when the user cancels the checkout sheet.
class NotchPayCancelledException extends NotchPayException {
  /// Creates a cancellation error, optionally overriding the [message].
  const NotchPayCancelledException(
      [super.message = 'Payment was cancelled by the user']);
}
