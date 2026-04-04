import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  // ================= LOGIN =================
  static Future<Map<String, dynamic>?> login({
    required String id,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "password": password,
        "role": role,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ================= UPDATE PROFILE =================
  static Future<bool> updateProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String location,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/mobile/update-profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "deviceId": id,
        "name": name,
        "email": email,
        "phone": phone,
        "location": location,
      }),

    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  // ================= GET PROFILE =================
  static Future<Map<String, dynamic>?> getProfile(String id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/mobile/profile/$id"),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("GET PROFILE ERR: $e");
      return null;
    }
  }

  // ================= CHANGE PASSWORD =================
  static Future<bool> changePassword({
    required String id,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/change-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );

    print("CHANGE PASS STATUS: ${response.statusCode}");
    print("CHANGE PASS RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }
}
