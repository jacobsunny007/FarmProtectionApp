import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detection_model.dart';
import '../config/api_config.dart';

class DetectionService {

/// Base URL of backend API
static const String baseUrl =
"${ApiConfig.baseUrl}/api/detections";

  /// Fetch detections for a specific device
  static Future<List<Detection>> fetchDetections(
    String deviceId, {
    String? sort,
    String? filterAnimal,
    String? filterRisk,
  }) async {
    try {
      var uriStr = "$baseUrl/$deviceId?";
      if (sort != null) uriStr += "sort=$sort&";
      if (filterAnimal != null) uriStr += "animal=$filterAnimal&";
      if (filterRisk != null) uriStr += "risk=$filterRisk&";

      final url = Uri.parse(uriStr);
      print("Fetching detections from: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Detection.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load detections");
      }
    } catch (e) {
      print("DetectionService Error: $e");
      throw Exception("Error fetching detections");
    }
  }

  /// Delete a detection by ID
  static Future<bool> deleteDetection(String id) async {
    try {
      final url = Uri.parse("$baseUrl/$id");
      print("Deleting detection: $url");

      final response = await http.delete(url).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      print("DetectionService Delete Error: $e");
      return false;
    }
  }
}