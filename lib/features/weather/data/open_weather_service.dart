import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_models.dart';

class OpenWeatherService {
  final String apiKey;
  final http.Client _client;

  OpenWeatherService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<WeatherBundle> fetchByCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) {
      throw Exception("City name is empty");
    }
    if (apiKey.trim().isEmpty) {
      throw Exception("Missing OpenWeather API key (.env)");
    }

    final currentUrl = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$trimmed&appid=$apiKey&units=metric",
    );

    final forecastUrl = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?q=$trimmed&appid=$apiKey&units=metric",
    );

    final currentRes = await _client.get(currentUrl);
    if (currentRes.statusCode != 200) {
      throw Exception("Current weather failed: ${currentRes.body}");
    }

    final forecastRes = await _client.get(forecastUrl);
    if (forecastRes.statusCode != 200) {
      throw Exception("Forecast failed: ${forecastRes.body}");
    }

    final currentJson = jsonDecode(currentRes.body) as Map<String, dynamic>;
    final forecastJson = jsonDecode(forecastRes.body) as Map<String, dynamic>;

    final current = CurrentWeather.fromJson(currentJson);
    final forecast = ForecastResponse.fromJson(forecastJson);

    return WeatherBundle(
      current: current,
      forecast: forecast.items,
    );
  }
}
