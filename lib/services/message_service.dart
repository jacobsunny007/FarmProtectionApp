import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MessageService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Fetch messages for a specific device (farm)
  static Future<List<dynamic>> getMessages(String deviceId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/messages/$deviceId")).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success']) {
          return decoded['data'];
        }
      }
    } catch (e) {
      print("MessageService getMessages ERR: $e");
    }
    return [];
  }

  // Send a new message
  static Future<bool> sendMessage({
    required String deviceId,
    required String senderId,
    required String senderRole,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/messages/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "deviceId": deviceId,
          "senderId": senderId,
          "senderRole": senderRole,
          "content": content,
        }),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return decoded['success'];
      }
    } catch (e) {
      print("MessageService sendMessage ERR: $e");
    }
    return false;
  }

  // Mark messages as read
  static Future<bool> markAsRead({
    required String deviceId,
    required String role,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/messages/$deviceId/read"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"role": role}),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'];
      }
    } catch (e) {
      print("MessageService markAsRead ERR: $e");
    }
    return false;
  }
}
