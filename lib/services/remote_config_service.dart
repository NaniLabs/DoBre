import 'dart:convert';

import 'package:http/http.dart' as http;

class RemoteConfigService {
  RemoteConfigService({required String endpoint, http.Client? client})
    : _client = client ?? http.Client(),
      _uri = Uri.parse(endpoint) {
    if (_uri.scheme != 'https') {
      throw ArgumentError(
        'RemoteConfigService requires an HTTPS endpoint. Received: $endpoint',
      );
    }
  }

  final http.Client _client;
  final Uri _uri;

  Future<Map<String, dynamic>> fetchConfig() async {
    final response = await _client.get(
      _uri,
      headers: const {
        'accept': 'application/json',
        'cache-control': 'no-cache',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RemoteConfigException(
        'Remote config request failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const RemoteConfigException(
        'Remote config response must be a JSON object.',
      );
    }

    return decoded;
  }
}

class RemoteConfigException implements Exception {
  const RemoteConfigException(this.message);

  final String message;

  @override
  String toString() => 'RemoteConfigException: $message';
}
