/// Weather snapshot data model ready for real API ingestion.
class WeatherData {
  const WeatherData({
    required this.temperatureC,
    required this.condition,
    this.highC,
    this.lowC,
    this.windSpeedKmh,
    this.windDirection,
    this.humidity,
    this.locationName,
  });

  final double temperatureC;
  final String condition;
  final double? highC;
  final double? lowC;
  final double? windSpeedKmh;
  final String? windDirection;
  final int? humidity;
  final String? locationName;

  int get tempInt => temperatureC.round();
}

/// Abstract weather service contract.
abstract class WeatherService {
  Future<WeatherData?> getWeather({double? latitude, double? longitude});
}

/// Default placeholder returning no data when no API key is provided.
class PlaceholderWeatherService implements WeatherService {
  const PlaceholderWeatherService();

  @override
  Future<WeatherData?> getWeather({double? latitude, double? longitude}) async {
    return null;
  }
}

/// Provider factory that checks `--dart-define=WEATHER_API_KEY`.
/// When unset or empty, yields [PlaceholderWeatherService].
/// When set, a production weather service implementation can plug in seamlessly.
class WeatherProvider {
  WeatherProvider._();

  static const String apiKey =
      String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');

  /// Shared location label matching the Home cockpit (fallback "Location off").
  static String currentLocationLabel = 'Location off';

  static WeatherService get service {
    if (apiKey.isEmpty) {
      return const PlaceholderWeatherService();
    }
    // When an API key is set via --dart-define=WEATHER_API_KEY, a real implementation can plug in.
    return const PlaceholderWeatherService();
  }
}
