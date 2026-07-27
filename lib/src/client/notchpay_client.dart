import 'dart:convert';

import 'package:http/http.dart' as http;

import 'notchpay_exception.dart';

/// Low level HTTP client for the NotchPay REST API.
///
/// This class deliberately stays close to the wire: it knows how to sign
/// requests and how to turn HTTP responses into typed exceptions, but it has
/// no knowledge of NotchPay resources (customers, payments, ...). Those live
/// in `lib/src/services`.
///
/// ### Security
///
/// * [publicKey] (`pk_...`) is safe to ship inside a mobile application. It
///   is the only credential required to run the checkout flow (initializing
///   and completing a payment).
/// * [privateKey] (`sk_...`) grants full access to the NotchPay account
///   (transfers, refunds, balance, recipients, ...). **Never** embed it in a
///   mobile app binary. Only supply it when this package is used from
///   trusted backend Dart code.
class NotchPayClient {
  /// Creates a client. See the class docs for the security implications of
  /// [privateKey].
  NotchPayClient({
    required this.publicKey,
    this.privateKey,
    http.Client? httpClient,
    this.baseUrl = 'https://api.notchpay.co',
  })  : assert(publicKey.trim().isNotEmpty, 'publicKey must not be empty'),
        _httpClient = httpClient ?? http.Client();

  /// The merchant public key, safe to embed in a mobile app.
  final String publicKey;

  /// The merchant private/secret key, backend use only. See class docs.
  final String? privateKey;

  /// Base URL of the NotchPay API. Overridable for testing.
  final String baseUrl;

  final http.Client _httpClient;

  /// Performs a `GET` request against [path].
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool requiresGrant = false,
  }) =>
      _send('GET', path, query: query, requiresGrant: requiresGrant);

  /// Performs a `POST` request against [path] with an optional JSON [body].
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresGrant = false,
  }) =>
      _send('POST', path, body: body, requiresGrant: requiresGrant);

  /// Performs a `PATCH` request against [path] with an optional JSON [body].
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresGrant = false,
  }) =>
      _send('PATCH', path, body: body, requiresGrant: requiresGrant);

  /// Performs a `DELETE` request against [path].
  Future<Map<String, dynamic>> delete(
    String path, {
    bool requiresGrant = false,
  }) =>
      _send('DELETE', path, requiresGrant: requiresGrant);

  /// Releases the resources used by the underlying HTTP client.
  void close() => _httpClient.close();

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool requiresGrant = false,
  }) async {
    final uri = _buildUri(path, query);
    final headers = _buildHeaders(requiresGrant: requiresGrant);
    final encodedBody = body == null ? null : jsonEncode(_pruneNulls(body));

    final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (encodedBody != null) request.body = encodedBody;
      final streamed = await _httpClient.send(request);
      response = await http.Response.fromStream(streamed);
    } catch (error) {
      throw NotchPayNetworkException(
        'Could not reach NotchPay servers: $error',
        cause: error,
      );
    }

    return _decode(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final base = Uri.parse(baseUrl);
    final normalizedBasePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: '$normalizedBasePath$normalizedPath',
      queryParameters: _stringifyQuery(query),
    );
  }

  Map<String, String>? _stringifyQuery(Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return null;
    final result = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        var index = 0;
        for (final item in value) {
          result['$key[$index]'] = '$item';
          index++;
        }
      } else {
        result[key] = '$value';
      }
    });
    return result;
  }

  Map<String, String> _buildHeaders({required bool requiresGrant}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': publicKey,
    };
    if (requiresGrant) {
      final key = privateKey;
      if (key == null || key.trim().isEmpty) {
        throw const NotchPayConfigurationException(
          'This operation requires a private key. Pass `privateKey` when '
          'creating NotchPay. Never bundle this key inside a mobile app; '
          'only use it from trusted backend Dart code.',
        );
      }
      headers['X-Grant'] = key;
    }
    return headers;
  }

  Map<String, dynamic> _pruneNulls(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    input.forEach((key, value) {
      if (value == null) return;
      if (value is Map<String, dynamic>) {
        result[key] = _pruneNulls(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      final body = response.body.isEmpty ? '{}' : response.body;
      final parsed = jsonDecode(body);
      decoded = parsed is Map<String, dynamic>
          ? parsed
          : <String, dynamic>{'data': parsed};
    } on FormatException catch (error) {
      throw NotchPayNetworkException(
        'Received an invalid response from NotchPay: $error',
        cause: error,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = _extractErrorMessage(decoded, response.statusCode);
    final errors = decoded['errors'];
    throw NotchPayApiException(
      statusCode: response.statusCode,
      message: message,
      code: decoded['code'] as String?,
      errors: errors is Map<String, dynamic> ? errors : null,
      raw: decoded,
    );
  }

  String _extractErrorMessage(Map<String, dynamic> decoded, int statusCode) {
    final message = decoded['message'];
    if (message is String && message.isNotEmpty) return message;
    return 'NotchPay request failed with status code $statusCode';
  }
}
