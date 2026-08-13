import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_constants.dart';
import 'notification_service.dart';
import 'auth_cache_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final NotificationService _notificationManager = NotificationService();
  final AuthCacheService _authCacheService = AuthCacheService();

  Future<void> syncMissedNotificationsHistory() async {
    try {
      List<String> locallyStoredIds = _notificationManager.getLocalNotificationIds();

      final String syncUrl = '${AppConstants.mgaServiceUrl}/consumer/notifications/sync-history';

      final response = await http.post(
        Uri.parse(syncUrl),

        headers: await _authCacheService.getSecureHeaders(),
        body: jsonEncode(locallyStoredIds),
      );

      if (response.statusCode == 200) {
        List<dynamic> missedAlerts = jsonDecode(response.body);
        _notificationManager.loadHistoryFromServer(missedAlerts);
      }
    } catch (_) {}
  }

  void disconnectWebSocket() {}
  void initializeWebSocket() {}
}
