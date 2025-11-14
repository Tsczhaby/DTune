import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// A lightweight client that authenticates against a Subsonic-compatible API.
class SubsonicAuthService {
  SubsonicAuthService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _clientName = 'DTune';
  static const _apiVersion = '1.16.1';
  static const _saltAlphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final http.Client _httpClient;
  final Random _random = Random.secure();

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
    final salt = _generateSalt();
    final token = md5.convert(utf8.encode('$password$salt')).toString();

    final pingUri = _buildPingUri(baseUrl, {
      'u': username,
      't': token,
      's': salt,
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

  Uri _normalizeBaseUrl(Uri uri) {
    if (!uri.hasScheme) {
      throw const SubsonicAuthException('Server URL must include a scheme.');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const SubsonicAuthException('Server URL must use HTTP or HTTPS.');
    }

    final normalizedPath = uri.path.isEmpty || uri.path == '/'
        ? '/'
        : uri.path.endsWith('/')
            ? uri.path
            : '${uri.path}/';

    return uri.replace(path: normalizedPath);
  }

  String _generateSalt([int length = 16]) {
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => _saltAlphabet.codeUnitAt(
          _random.nextInt(_saltAlphabet.length),
        ),
      ),
    );
  }
}

class SubsonicAuthException implements Exception {
  const SubsonicAuthException(this.message);

  final String message;

  @override
  String toString() => 'SubsonicAuthException: $message';
}
