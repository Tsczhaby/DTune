import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A lightweight client that authenticates against a Subsonic-compatible API.
class SubsonicAuthService {
  SubsonicAuthService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _clientName = 'DTune';
  static const _apiVersion = '1.16.1';
  static const defaultBaseUrlString = 'http://4.180.15.163:4533';
  static final Uri defaultBaseUri = Uri.parse('$defaultBaseUrlString/');

  final http.Client _httpClient;

  /// Attempts to authenticate with the provided [baseUrl], [username], and
  /// [password].
  ///
  /// Throws a [SubsonicAuthException] when the credentials are invalid or the
  /// server cannot be reached.
  Future<void> authenticate({
    required Uri baseUrl,
    required String username,
    required String password,
  }) async {
    final pingUri = _buildPingUri(baseUrl, {
      'u': username,
      'p': password,
      'v': _apiVersion,
      'c': _clientName,
      'f': 'json',
    });

    http.Response response;
    try {
      response = await _httpClient
          .get(pingUri)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const SubsonicAuthException(
        'Connection timed out. Please try again.',
      );
    } on Object {
      throw const SubsonicAuthException(
        'Unable to reach the server. Check your connection and URL.',
      );
    }

    if (response.statusCode >= 400) {
      throw SubsonicAuthException(
        'Server responded with status code ${response.statusCode}.',
      );
    }

    Map<String, dynamic> payload;
    try {
      payload = json.decode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const SubsonicAuthException(
        'Received an unexpected response from the server.',
      );
    }

    final root = payload['subsonic-response'];
    if (root is! Map<String, dynamic>) {
      throw const SubsonicAuthException(
        'Received an unexpected response from the server.',
      );
    }

    final status = root['status'] as String?;
    if (status != 'ok') {
      final error = root['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String?
          : null;

      throw SubsonicAuthException(
        message ?? 'Authentication failed. Please verify your credentials.',
      );
    }
  }

  /// Releases the underlying HTTP client.
  void dispose() {
    _httpClient.close();
  }

  Uri _buildPingUri(Uri baseUrl, Map<String, String> queryParameters) {
    final sanitized = _normalizeBaseUrl(baseUrl);
    final ping = sanitized.resolve('rest/ping.view');

    return ping.replace(queryParameters: queryParameters);
  }

  Uri _normalizeBaseUrl(Uri _) {
    final normalizedPath = defaultBaseUri.path.endsWith('/')
        ? defaultBaseUri.path
        : '${defaultBaseUri.path}/';

    return defaultBaseUri.replace(path: normalizedPath);
  }
}

class SubsonicAuthException implements Exception {
  const SubsonicAuthException(this.message);

  final String message;

  @override
  String toString() => 'SubsonicAuthException: $message';
}
