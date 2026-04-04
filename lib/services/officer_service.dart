import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/detection_model.dart';

class OfficerService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Fetch Dashboard Stats
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/officers/dashboard")).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("OfficerService getDashboardStats ERR: $e");
    }
    return null;
  }

  // Fetch Alerts (with optional filters)
  static Future<List<Detection>> getAlerts({
    String? riskLevel,
    String? animal,
    String? date,
  }) async {
    try {
      Uri uri = Uri.parse("$baseUrl/api/officers/alerts");
      Map<String, String> queryParams = {};
      if (riskLevel != null && riskLevel.isNotEmpty) queryParams['riskLevel'] = riskLevel;
      if (animal != null && animal.isNotEmpty) queryParams['animal'] = animal;
      if (date != null && date.isNotEmpty) queryParams['date'] = date;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Detection.fromJson(json)).toList();
      }
    } catch (e) {
      print("OfficerService getAlerts ERR: $e");
    }
    return [];
  }

  // Update Alert
  static Future<bool> updateAlertStatus({
    required String id,
    String? status,
    String? notes,
    String? officerNote,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (status != null) body['status'] = status;
      if (notes != null) body['notes'] = notes;
      if (officerNote != null) body['officerNote'] = officerNote;

      final response = await http.put(
        Uri.parse("$baseUrl/api/officers/alerts/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print("OfficerService updateAlertStatus ERR: $e");
    }
    return false;
  }

  // Delete Alert permanently
  static Future<bool> deleteAlert(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/detections/$id"),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print("OfficerService deleteAlert ERR: $e");
    }
    return false;
  }

  // Fetch top 2 high-risk pending alerts for dashboard preview
  static Future<List<Detection>> getHighRiskAlerts({int limit = 2}) async {
    try {
      final uri = Uri.parse("$baseUrl/api/officers/alerts")
          .replace(queryParameters: {'riskLevel': 'high', 'status': 'Pending'});
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        final alerts = data.map((j) => Detection.fromJson(j)).toList();
        return alerts.take(limit).toList();
      }
    } catch (e) {
      print("OfficerService getHighRiskAlerts ERR: $e");
    }
    return [];
  }

  // Fetch AI Insights
  static Future<Map<String, dynamic>?> getInsights() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/officers/insights")).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("OfficerService getInsights ERR: $e");
    }
    return null;
  }

  // Fetch Monitored Farms
  static Future<List<dynamic>> getFarms() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/officers/farms")).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("OfficerService getFarms ERR: $e");
    }
    return [];
  }

  // Toggle Farm Monitoring
  static Future<bool> toggleMonitoring(String deviceId, bool enabled) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/devices/toggle-monitoring/$deviceId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"enabled": enabled}),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print("OfficerService toggleMonitoring ERR: $e");
    }
    return false;
  }
}
