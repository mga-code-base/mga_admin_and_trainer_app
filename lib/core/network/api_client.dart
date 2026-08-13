import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';
import '../../services/auth_cache_service.dart';

class ApiClient {
  final AuthCacheService _authCacheService;
  final http.Client _client;

  ApiClient(this._authCacheService, {http.Client? client}) : _client = client ?? http.Client();

  static const Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json',
  };

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse('${AppConstants.mgaServiceUrl}$path');
    return query == null ? base : base.replace(queryParameters: query);
  }

  Future<Map<String, String>> _resolveHeaders(bool auth) async {
    return auth ? await _authCacheService.getSecureHeaders() : _publicHeaders;
  }

  Future<http.Response> get(String path, {Map<String, String>? query, bool auth = true}) async {
    return _client.get(_uri(path, query), headers: await _resolveHeaders(auth));
  }

  Future<http.Response> post(String path, {Object? body, bool auth = true}) async {
    return _client.post(
      _uri(path),
      headers: await _resolveHeaders(auth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String path, {Object? body, Map<String, String>? query, bool auth = true}) async {
    return _client.put(
      _uri(path, query),
      headers: await _resolveHeaders(auth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    return _client.delete(_uri(path), headers: await _resolveHeaders(auth));
  }
}