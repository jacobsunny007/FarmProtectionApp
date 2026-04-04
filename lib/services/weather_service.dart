import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final String? cityName; // Added city name

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, {String? cityName}) {
    final current = json['current'];
    return WeatherData(
      temperature: current['temperature_2m'].toDouble(),
      humidity: current['relative_humidity_2m'].toInt(),
      weatherCode: current['weather_code'] ?? 0,
      windSpeed: current['wind_speed_10m'].toDouble(),
      cityName: cityName,
    );
  }

  String get condition {
    switch (weatherCode) {
      case 0: return 'Clear Sky';
      case 1: case 2: case 3: return 'Partly Cloudy';
      case 45: case 48: return 'Foggy';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }
}

class WeatherService {
  static Future<WeatherData?> fetchCurrentWeather({String? profileLocation}) async {
    try {
      double lat;
      double lng;
      String? matchedCity = profileLocation;

      if (profileLocation != null && profileLocation.isNotEmpty && profileLocation != "Unknown") {
        // Use Geocoding to get coordinates from Profile Location
        try {
          List<Location> locations = await locationFromAddress(profileLocation);
          if (locations.isNotEmpty) {
            lat = locations.first.latitude;
            lng = locations.first.longitude;
          } else {
            throw Exception("City not found");
          }
        } catch (e) {
          // Fallback if Geocoding fails
          return await _fetchFromGPS();
        }
      } else {
        return await _fetchFromGPS();
      }

      return await _fetchFromCoords(lat, lng, cityName: matchedCity);
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  static Future<WeatherData?> _fetchFromGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    return await _fetchFromCoords(position.latitude, position.longitude, cityName: "Current Location");
  }

  static Future<WeatherData?> _fetchFromCoords(double lat, double lng, {String? cityName}) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m');

    final response = await http.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherData.fromJson(data, cityName: cityName);
    }
    return null;
  }
}
