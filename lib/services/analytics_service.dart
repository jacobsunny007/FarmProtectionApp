import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AnalyticsSummary {
  final String deviceId;
  final int totalDetections;
  final String mostFrequentAnimal;
  final int highRiskCount;
  final String mostDangerousAnimal;
  final String peakTime;

  AnalyticsSummary({
    required this.deviceId,
    required this.totalDetections,
    required this.mostFrequentAnimal,
    required this.highRiskCount,
    this.mostDangerousAnimal = 'None',
    this.peakTime = 'N/A',
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      deviceId: json['deviceId'] ?? '',
      totalDetections: json['totalDetections'] ?? 0,
      mostFrequentAnimal: json['mostFrequentAnimal'] ?? 'None',
      highRiskCount: json['highRiskCount'] ?? 0,
      mostDangerousAnimal: json['mostDangerousAnimal'] ?? 'None',
      peakTime: json['peakTime'] ?? 'N/A',
    );
  }
}

class ChartDataPoint {
  final String label;
  final int count;

  ChartDataPoint({
    required this.label,
    required this.count,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['_id']?.toString() ??
          json['date']?.toString() ??
          json['label']?.toString() ??
          'Unknown',
      count: json['count'] ?? 0,
    );
  }
}

class AnalyticsService {

  static const String baseUrl =
      "${ApiConfig.baseUrl}/api/analytics";

  // SUMMARY DATA
  static Future<AnalyticsSummary> getSummary(String deviceId) async {

    final response =
    await http.get(Uri.parse("$baseUrl/summary/$deviceId"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return AnalyticsSummary.fromJson(decoded);
    }

    throw Exception("Failed to load analytics summary");
  }

  // DETECTION HISTORY (Line graph)
  static Future<List<ChartDataPoint>> getHistory(String deviceId) async {
    return _fetchChartData("$baseUrl/history/$deviceId");
  }

  // ANIMAL FREQUENCY (Bar chart)
  static Future<List<ChartDataPoint>> getAnimals(String deviceId) async {
    return _fetchChartData("$baseUrl/animals/$deviceId");
  }

  // RISK DISTRIBUTION (Pie chart)
  static Future<List<ChartDataPoint>> getRisks(String deviceId) async {
    return _fetchChartData("$baseUrl/risks/$deviceId");
  }

  // GENERIC CHART FETCHER
  static Future<List<ChartDataPoint>> _fetchChartData(String url) async {

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body);

      // Backend returns a List
      if (decoded is List) {
        return decoded
            .map<ChartDataPoint>((e) => ChartDataPoint.fromJson(e))
            .toList();
      }

      // Fallback safety
      if (decoded is Map && decoded.containsKey("value")) {
        final List values = decoded["value"];
        return values
            .map<ChartDataPoint>((e) => ChartDataPoint.fromJson(e))
            .toList();
      }

      return [];
    }

    throw Exception("Failed to load chart data from $url");
  }

  // ================= GLOBAL OFFICER ENDPOINTS =================

  static Future<AnalyticsSummary> getGlobalSummary() async {
    final response = await http.get(Uri.parse("$baseUrl/global/summary"));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return AnalyticsSummary.fromJson(decoded);
    }
    throw Exception("Failed to load global analytics summary");
  }

  static Future<List<ChartDataPoint>> getGlobalHistory() async {
    return _fetchChartData("$baseUrl/global/history");
  }

  static Future<List<ChartDataPoint>> getGlobalAnimals() async {
    return _fetchChartData("$baseUrl/global/animals");
  }

  static Future<List<ChartDataPoint>> getGlobalRisks() async {
    return _fetchChartData("$baseUrl/global/risks");
  }

  static Future<List<ChartDataPoint>> getGlobalTime() async {
    return _fetchChartData("$baseUrl/global/time");
  }
}