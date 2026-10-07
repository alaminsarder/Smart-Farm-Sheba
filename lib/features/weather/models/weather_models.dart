class WeatherBundle {
  final CurrentWeather current;
  final List<ForecastItem> forecast;

  const WeatherBundle({
    required this.current,
    required this.forecast,
  });
}

class CurrentWeather {
  final String cityName;
  final String main;
  final String description;
  final String icon;

  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int visibility; // meters

  final int timezone; // seconds from UTC
  final DateTime updatedAtUtc;

  const CurrentWeather({
    required this.cityName,
    required this.main,
    required this.description,
    required this.icon,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.timezone,
    required this.updatedAtUtc,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final weather0 = (json["weather"] as List).first as Map<String, dynamic>;
    final mainJson = json["main"] as Map<String, dynamic>;
    final windJson = (json["wind"] as Map<String, dynamic>?) ?? {};

    return CurrentWeather(
      cityName: (json["name"] ?? "").toString(),
      main: (weather0["main"] ?? "").toString(),
      description: (weather0["description"] ?? "").toString(),
      icon: (weather0["icon"] ?? "").toString(),
      temp: (mainJson["temp"] as num).toDouble(),
      feelsLike: (mainJson["feels_like"] as num).toDouble(),
      humidity: (mainJson["humidity"] as num).toInt(),
      windSpeed: ((windJson["speed"] ?? 0) as num).toDouble(),
      visibility: ((json["visibility"] ?? 0) as num).toInt(),
      timezone: ((json["timezone"] ?? 0) as num).toInt(),
      updatedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        ((json["dt"] ?? 0) as num).toInt() * 1000,
        isUtc: true,
      ),
    );
  }
}

class ForecastResponse {
  final List<ForecastItem> items;
  const ForecastResponse({required this.items});

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    final list = (json["list"] as List).cast<Map<String, dynamic>>();
    return ForecastResponse(
      items: list.map(ForecastItem.fromJson).toList(),
    );
  }
}

class ForecastItem {
  final DateTime timeUtc;
  final double temp;
  final String main;
  final String description;
  final String icon;

  const ForecastItem({
    required this.timeUtc,
    required this.temp,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final dt = (json["dt"] as num).toInt();
    final mainJson = json["main"] as Map<String, dynamic>;
    final weather0 = (json["weather"] as List).first as Map<String, dynamic>;

    return ForecastItem(
      timeUtc: DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true),
      temp: (mainJson["temp"] as num).toDouble(),
      main: (weather0["main"] ?? "").toString(),
      description: (weather0["description"] ?? "").toString(),
      icon: (weather0["icon"] ?? "").toString(),
    );
  }
}
