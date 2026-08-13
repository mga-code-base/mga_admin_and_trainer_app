import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/app_constants.dart';

class AuthCacheService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<int> checkPrimaryAdminExistsCode() async {
    try {

      final String existsUrl = '${AppConstants.mgaServiceUrl}/admins/primaryexists';
      final response = await http.get(Uri.parse(existsUrl));
      if (response.statusCode == 200) {
        return int.tryParse(response.body.trim()) ?? -1;
      }
      return -1;
    } catch (_) {
      return -1;
    }
  }

  Future<Map<String, dynamic>> setupAdminPassword(String password) async {
    try {

      final Uri requestUrl = Uri.parse('${AppConstants.mgaServiceUrl}/admins/createprimary').replace(
        queryParameters: {'password': password},
      );

      final response = await http.post(requestUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 201) return {'success': true, 'message': 'Admin password setup successful!'};
      if (response.statusCode == 409) return {'success': false, 'message': 'Conflict while Creating Primary Admin'};
      return {'success': false, 'message': 'Setup failed. Status code: ${response.statusCode}'};
    } catch (_) {
      return {'success': false, 'message': 'Server connection error. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> loginWithPlainResponse(String username, String password, String role) async {
    try {
      String operationalPath = '/admins/login';
      if (role.toLowerCase() == 'trainer') {
        operationalPath = '/trainers/login';
      }

      final Uri requestUrl = Uri.parse('${AppConstants.mgaServiceUrl}$operationalPath');

      final response = await http.post(
        requestUrl,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'username': username, 'password': password, 'role': role}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String token = responseData['token'] ?? '';
        final String parsedRole = responseData['role'] ?? role;
        final String branchId = responseData['branchId']?.toString() ?? '';

        if (token.isNotEmpty) {
          await writeSecureToken('auth_token', token);
          await writeSecureToken('token_issued_at', DateTime.now().millisecondsSinceEpoch.toString());
        }
        await writeSecureToken('user_role', parsedRole);

        if (branchId.isNotEmpty) {
          await writeSecureToken('logged_in_branch_id', branchId);
        }

        if (parsedRole.toLowerCase() == 'admin') {
          final String adminId = responseData['personId']?.toString() ?? '';
          if (adminId.isNotEmpty) await writeSecureToken('logged_in_admin_id', adminId);
        } else if (parsedRole.toLowerCase() == 'trainer') {
          final String trainerId = responseData['personId']?.toString() ?? '';
          if (trainerId.isNotEmpty) await writeSecureToken('logged_in_trainer_id', trainerId);
        }

        return {
          'httpSuccess': true,
          'isActive': responseData['isActive'] ?? false,
          'message': responseData['message'] ?? 'Welcome back!',
          'token': token,
          'role': parsedRole,
          'personId': responseData['personId'] ?? '',
          'branchId': branchId,
        };
      }
      return {'httpSuccess': false, 'message': responseData['message'] ?? 'Authentication failed'};
    } catch (_) {
      return {'httpSuccess': false, 'message': 'Server connection error.'};
    }
  }

  Future<void> writeSecureToken(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecureToken(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<String> getCachedUsername() async {
    return await _secureStorage.read(key: 'user_role') ?? 'UnknownUser';
  }

  Future<String> getCachedAdminId() async {
    return await _secureStorage.read(key: 'logged_in_admin_id') ?? 'UnknownAdmin';
  }

  Future<String> getCachedTrainerId() async {
    return await _secureStorage.read(key: 'logged_in_trainer_id') ?? 'UnknownTrainer';
  }

  Future<String> getCachedBranchId() async {
    return await _secureStorage.read(key: 'logged_in_branch_id') ?? 'UnknownBranch';
  }

  /// The cached auth token is auto-deleted 15 minutes after login. There's
  /// no background timer keeping this running while the app is closed —
  /// this is a lazy check applied the next time the token is read (i.e. on
  /// the next API call), which is the same moment it would matter anyway.
  static const Duration _tokenTtl = Duration(minutes: 15);

  Future<bool> _isTokenExpired() async {
    final String? issuedAtRaw = await _secureStorage.read(key: 'token_issued_at');
    if (issuedAtRaw == null) return false;
    final int? issuedAtMillis = int.tryParse(issuedAtRaw);
    if (issuedAtMillis == null) return false;
    final DateTime issuedAt = DateTime.fromMillisecondsSinceEpoch(issuedAtMillis);
    return DateTime.now().difference(issuedAt) > _tokenTtl;
  }

  /// Returns the cached token, or null if it's missing or has expired.
  /// Expiry wipes the whole session (not just the token), matching what
  /// [clearSession] already does for logout.
  Future<String?> getValidAuthToken() async {
    if (await _isTokenExpired()) {
      await clearSession();
      return null;
    }
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, String>> getSecureHeaders() async {
    final token = await getValidAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'token_issued_at');
    await _secureStorage.delete(key: 'user_role');
    await _secureStorage.delete(key: 'logged_in_admin_id');
    await _secureStorage.delete(key: 'logged_in_trainer_id');
    await _secureStorage.delete(key: 'logged_in_branch_id');
  }
}