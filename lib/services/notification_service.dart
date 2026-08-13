import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier =
  ValueNotifier<List<Map<String, dynamic>>>([]);

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  List<String> getLocalNotificationIds() {
    return notificationsNotifier.value
        .map((notice) => notice['notificationId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  void loadHistoryFromServer(List<dynamic> historicalList) {
    final currentList = List<Map<String, dynamic>>.from(notificationsNotifier.value);
    int newUnreadCount = unreadCountNotifier.value;

    for (var item in historicalList) {
      final Map<String, dynamic> notice = Map<String, dynamic>.from(item);
      bool alreadyExists = currentList.any((existing) =>
      existing['notificationId'] == notice['notificationId']);

      if (!alreadyExists) {
        notice['isRead'] = false;
        notice['receivedAt'] = DateTime.now().millisecondsSinceEpoch;
        currentList.add(notice);
        newUnreadCount++;
      }
    }

    currentList.sort((a, b) => (b['receivedAt'] ?? 0).compareTo(a['receivedAt'] ?? 0));
    notificationsNotifier.value = currentList;
    unreadCountNotifier.value = newUnreadCount;
  }

  void addNotification(Map<String, dynamic> payload) {
    final updatedList = List<Map<String, dynamic>>.from(notificationsNotifier.value);
    bool alreadyExists = updatedList.any((existing) =>
    existing['notificationId'] == payload['notificationId']);
    if (alreadyExists) return;

    final Map<String, dynamic> trackedPayload = Map<String, dynamic>.from(payload);
    trackedPayload['receivedAt'] = DateTime.now().millisecondsSinceEpoch;
    trackedPayload['isRead'] = false;

    updatedList.insert(0, trackedPayload);
    notificationsNotifier.value = updatedList;
    unreadCountNotifier.value++;
    pruneExpiredNotifications();
  }

  void markAllAsRead() {
    unreadCountNotifier.value = 0;
    final currentList = notificationsNotifier.value;
    if (currentList.isEmpty) return;

    final updatedList = currentList.map((notice) {
      final Map<String, dynamic> mutableNotice = Map<String, dynamic>.from(notice);
      if (mutableNotice['isRead'] == false) {
        mutableNotice['isRead'] = true;
        mutableNotice['readAt'] = DateTime.now().millisecondsSinceEpoch;
      }
      return mutableNotice;
    }).toList();

    notificationsNotifier.value = updatedList;
    pruneExpiredNotifications();
  }

  void pruneExpiredNotifications() {
    final currentList = notificationsNotifier.value;
    if (currentList.isEmpty) return;

    final int twentyFourHoursAgo = DateTime.now()
        .subtract(const Duration(hours: 24))
        .millisecondsSinceEpoch;

    final List<Map<String, dynamic>> freshNotices = currentList.where((notice) {
      final bool isRead = notice['isRead'] ?? false;
      final int? readAtTimestamp = notice['readAt'];

      if (!isRead) return true;
      if (readAtTimestamp != null) {
        return readAtTimestamp > twentyFourHoursAgo;
      }
      return true;
    }).toList();

    notificationsNotifier.value = freshNotices;
  }
}
