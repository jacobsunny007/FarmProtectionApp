import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DashboardStats {
  final int cameraCount;
  final int activeCameras;
  final String lastDetectedAnimal;
  final String systemUptime;
  final String lastSyncTime;
  final String systemStatus;

  DashboardStats({
    required this.cameraCount,
    required this.activeCameras,
    required this.lastDetectedAnimal,
    required this.systemUptime,
    required this.lastSyncTime,
    required this.systemStatus,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      cameraCount: json['cameraCount'] ?? 0,
      activeCameras: json['activeCameras'] ?? 0,
      lastDetectedAnimal: json['lastDetectedAnimal'] ?? 'None',
      systemUptime: json['systemUptime'] ?? '0h',
      lastSyncTime: json['lastSyncTime'] ?? 'Never',
      systemStatus: json['systemStatus'] ?? 'Unknown',
    );
  }
}

class DashboardService {
  static const String baseUrl = "${ApiConfig.baseUrl}/api/dashboard";

  /// Fetch dashboard stats for a device
  static Future<DashboardStats> getStats(String deviceId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/stats/$deviceId"))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return DashboardStats.fromJson(decoded);
      }

      throw Exception("Failed to load dashboard stats");
    } catch (e) {
      print("DashboardService Error: $e");
      throw Exception("Error fetching dashboard stats");
    }
  }
}
