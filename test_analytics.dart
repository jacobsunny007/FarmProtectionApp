import 'package:http/http.dart' as http;
import 'dart:convert';

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

class AnalyticsSummary {
  final String deviceId;
  final int totalDetections;
  final String mostFrequentAnimal;
  final int highRiskCount;

  AnalyticsSummary({
    required this.deviceId,
    required this.totalDetections,
    required this.mostFrequentAnimal,
    required this.highRiskCount,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      deviceId: json['deviceId'] ?? '',
      totalDetections: json['totalDetections'] ?? 0,
      mostFrequentAnimal: json['mostFrequentAnimal'] ?? 'None',
      highRiskCount: json['highRiskCount'] ?? 0,
    );
  }
}

void main() async {
  String baseUrl = "http://192.168.1.4:5000/api/analytics";
  String deviceId = "DEV-001";
  
  try {
    print("Fetching all 4...");
    final results = await Future.wait([
      getSummary(baseUrl, deviceId),
      getChartData("$baseUrl/history/$deviceId"),
      getChartData("$baseUrl/animals/$deviceId"),
      getChartData("$baseUrl/risks/$deviceId"),
    ]);

    print("Success. Results length: ${results.length}");
  } catch(e, s) {
    print("ERROR CAUGHT: $e");
    print("STACKTRACE: $s");
  }
}

Future<AnalyticsSummary> getSummary(String baseUrl, String deviceId) async {
  final response = await http.get(Uri.parse("$baseUrl/summary/$deviceId"));
  final decoded = jsonDecode(response.body);
  return AnalyticsSummary.fromJson(decoded);
}

Future<List<ChartDataPoint>> getChartData(String url) async {
  final response = await http.get(Uri.parse(url));
  final decoded = jsonDecode(response.body);
  if (decoded is List) {
    return decoded.map<ChartDataPoint>((e) => ChartDataPoint.fromJson(e)).toList();
  }
  return [];
}
