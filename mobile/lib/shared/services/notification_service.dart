import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/storage_service.dart';

/// Notification Service
class NotificationService {
  final ApiClient _api;
  final StorageService _storage;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._api, this._storage);

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  // Show local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tenkbooks_notification',
      '万卷书苑通知',
      channelDescription: '万卷书苑应用通知',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tenkbooks_reminder',
      '阅读提醒',
      channelDescription: '阅读提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime.toUtc(),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get notifications from server
  Future<ApiResult<NotificationList>> getNotifications({
    int page = 1,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _api.get('/notifications', queryParameters: {
        'page': page,
        'size': size,
        if (unreadOnly) 'unreadOnly': true,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      return ApiResult.success(NotificationList.fromJson(data));
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Mark as read
  Future<ApiResult<bool>> markAsRead(String notificationId) async {
    try {
      final response = await _api.post('/notifications/$notificationId/read');
      return ApiResult.success(response.data['data']['success'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Mark all as read
  Future<ApiResult<bool>> markAllAsRead() async {
    try {
      final response = await _api.post('/notifications/read-all');
      return ApiResult.success(response.data['success'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}

class NotificationList {
  final List<AppNotification> items;
  final int total;
  final int unreadCount;

  NotificationList({
    required this.items,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) {
    return NotificationList(
      items: (json['items'] as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      unreadCount: json['unreadCount'] as int,
    );
  }
}

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String content;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
