import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../data/open_weather_service.dart';
import '../models/weather_models.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final OpenWeatherService _service;
  late final TextEditingController _cityCtrl;

  Future<WeatherBundle>? _future;

  @override
  void initState() {
    super.initState();

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    _service = OpenWeatherService(apiKey: apiKey);

    // ✅ Dhaka fallback বাদ — DEFAULT_CITY থাকলে সেটাই, না থাকলে খালি
    final defaultCity = (dotenv.env['DEFAULT_CITY'] ?? '').trim();
    _cityCtrl = TextEditingController(text: defaultCity);

    if (defaultCity.isNotEmpty) {
      _future = _service.fetchByCity(defaultCity);
    } else {
      _future = null;
    }
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final city = _cityCtrl.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a city name")),
      );
      return;
    }
    setState(() => _future = _service.fetchByCity(city));
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.trim().isEmpty) {
      return const Scaffold(
        body: Center(child: Text("OPENWEATHER_API_KEY missing in .env")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _searchBar(),
          const SizedBox(height: 14),

          // ✅ শুরুতে কিছু লোড না থাকলে নির্দেশনা দেখাবে
          if (_future == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "Type a city name and press search.",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          else
            FutureBuilder<WeatherBundle>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingCard();
                }
                if (snapshot.hasError) {
                  return _ErrorCard(
                    message: snapshot.error.toString(),
                    onRetry: _search,
                  );
                }
                final data = snapshot.data!;
                return Column(
                  children: [
                    _currentWeatherCard(context, data.current),
                    const SizedBox(height: 14),
                    _rainAlertCard(context, data),
                    const SizedBox(height: 14),
                    _forecastCard(context, data), // ✅ overflow fixed here
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _cityCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: "Search city (e.g., Dhaka)",
              prefixIcon: const Icon(Icons.location_city_rounded),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _search,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Icon(Icons.search_rounded),
          ),
        ),
      ],
    );
  }

  Widget _currentWeatherCard(BuildContext context, CurrentWeather w) {
    final localUpdated = w.updatedAtUtc.add(Duration(seconds: w.timezone));
    final updatedStr = DateFormat("EEE, dd MMM • hh:mm a").format(localUpdated);
    final iconUrl = "https://openweathermap.org/img/wn/${w.icon}@2x.png";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${w.main} • ${w.description}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  "${w.temp.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Feels like ${w.feelsLike.toStringAsFixed(1)}°C",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  "Updated: $updatedStr",
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _miniStat(Icons.water_drop_rounded, "${w.humidity}%"),
                    const SizedBox(width: 12),
                    _miniStat(Icons.air_rounded,
                        "${w.windSpeed.toStringAsFixed(1)} m/s"),
                  ],
                ),
              ],
            ),
          ),
          Image.network(
            iconUrl,
            width: 70,
            height: 70,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.cloud_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ✅ OVERFLOW FIXED: height increased + compact content + FittedBox
  Widget _forecastCard(BuildContext context, WeatherBundle data) {
    final items = data.forecast.take(8).toList(); // ~24 hours
    final tz = data.current.timezone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Next 24 Hours Forecast",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 128, // ✅ 110 -> 128 (overflow আর হবে না)
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final f = items[i];
                final local = f.timeUtc.add(Duration(seconds: tz));
                final timeStr = DateFormat("hh a").format(local);
                final iconUrl =
                    "https://openweathermap.org/img/wn/${f.icon}@2x.png";

                return SizedBox(
                  width: 96,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          child: Text(
                            timeStr,
                            maxLines: 1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.network(
                            iconUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.cloud_rounded),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          child: Text(
                            "${f.temp.toStringAsFixed(0)}°C",
                            maxLines: 1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _rainAlertCard(BuildContext context, WeatherBundle data) {
    final currentIsRain = _isRainLike(data.current.main);
    final upcomingRain = data.forecast.take(8).any((f) => _isRainLike(f.main));
    final showAlert = currentIsRain || upcomingRain;

    if (!showAlert) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.25)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Expanded(child: Text("No rain alert for the next 24 hours.")),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.30)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
                "Rain alert: plan irrigation & pesticide spraying carefully."),
          ),
        ],
      ),
    );
  }

  bool _isRainLike(String main) {
    final m = main.toLowerCase();
    return m.contains("rain") ||
        m.contains("drizzle") ||
        m.contains("thunderstorm");
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text("Loading weather..."),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Failed to load weather",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry"),
            ),
          ),
        ],
      ),
    );
  }
}
