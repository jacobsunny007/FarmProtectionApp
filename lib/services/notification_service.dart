import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = "${ApiConfig.baseUrl}/api/notifications";

  /// Fetch notifications for a device
  static Future<List<AppNotification>> getNotifications(String deviceId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/$deviceId"))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => AppNotification.fromJson(e)).toList();
      }

      throw Exception("Failed to load notifications");
    } catch (e) {
      print("NotificationService Error: $e");
      throw Exception("Error fetching notifications");
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadCount(String deviceId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/$deviceId/count"))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['unreadCount'] ?? 0;
      }

      return 0;
    } catch (e) {
      print("NotificationService Count Error: $e");
      return 0;
    }
  }

  /// Mark single notification as read
  static Future<bool> markAsRead(String id) async {
    try {
      final response = await http
          .put(Uri.parse("$baseUrl/$id/read"))
          .timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      print("NotificationService MarkRead Error: $e");
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllAsRead(String deviceId) async {
    try {
      final response = await http
          .put(Uri.parse("$baseUrl/$deviceId/read-all"))
          .timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      print("NotificationService MarkAllRead Error: $e");
      return false;
    }
  }
}
