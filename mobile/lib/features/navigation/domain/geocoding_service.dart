import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Public demo server URL. Replace with dedicated Nominatim instance in production.
const String kNominatimBaseUrl = 'https://nominatim.openstreetmap.org';

/// Structured geocoding place search or reverse lookup result.
class PlaceSearchResult {
  const PlaceSearchResult({
    required this.name,
    required this.displayName,
    required this.location,
    this.category,
  });

  final String name;
  final String displayName;
  final LatLng location;
  final String? category;

  @override
  String toString() => 'PlaceSearchResult(name: $name, location: $location)';
}

/// Abstract geocoding service contract.
abstract class GeocodingService {
  /// Forward search: query -> matching places.
  Future<List<PlaceSearchResult>> search(String query);

  /// Reverse lookup: coordinates -> place name.
  Future<PlaceSearchResult?> reverseGeocode(LatLng location);
}

/// Production OpenStreetMap Nominatim implementation.
/// Adheres strictly to Nominatim usage policy:
/// - Custom descriptive User-Agent
/// - Rate limited / throttled
/// - One concurrent request at a time
/// - Strong in-memory caching
class NominatimGeocodingService implements GeocodingService {
  NominatimGeocodingService({
    this.baseUrl = kNominatimBaseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  final Map<String, List<PlaceSearchResult>> _searchCache = {};
  final Map<String, PlaceSearchResult?> _reverseCache = {};

  DateTime? _lastRequestTime;
  Completer<void>? _activeRequestLock;

  @override
  Future<List<PlaceSearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final cacheKey = trimmed.toLowerCase();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    return _enqueueRequest(() async {
      try {
        final uri = Uri.parse(
          '$baseUrl/search?q=${Uri.encodeComponent(trimmed)}&format=json&limit=5&addressdetails=1',
        );

        final response = await _httpClient.get(
          uri,
          headers: {
            'User-Agent': 'CAMP-App/1.0 (contact: support@camp-moto.app)',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode != 200) {
          return <PlaceSearchResult>[];
        }

        final data = json.decode(response.body) as List<dynamic>;
        final results = <PlaceSearchResult>[];

        for (final item in data) {
          final map = item as Map<String, dynamic>;
          final lat = double.tryParse(map['lat']?.toString() ?? '');
          final lon = double.tryParse(map['lon']?.toString() ?? '');
          if (lat == null || lon == null) continue;

          final displayName = (map['display_name'] as String?) ?? trimmed;
          final parts = displayName.split(',');
          final shortName = parts.take(2).join(',').trim();

          results.add(
            PlaceSearchResult(
              name: shortName.isNotEmpty ? shortName : trimmed,
              displayName: displayName,
              location: LatLng(lat, lon),
              category: map['type'] as String?,
            ),
          );
        }

        _searchCache[cacheKey] = results;
        return results;
      } catch (_) {
        return <PlaceSearchResult>[];
      }
    });
  }

  @override
  Future<PlaceSearchResult?> reverseGeocode(LatLng location) async {
    // Cache by coordinates rounded to 3 decimal places (~110m resolution)
    final cacheKey =
        '${location.latitude.toStringAsFixed(3)},${location.longitude.toStringAsFixed(3)}';
    if (_reverseCache.containsKey(cacheKey)) {
      return _reverseCache[cacheKey];
    }

    return _enqueueRequest(() async {
      try {
        final uri = Uri.parse(
          '$baseUrl/reverse?lat=${location.latitude.toStringAsFixed(6)}&lon=${location.longitude.toStringAsFixed(6)}&format=json&zoom=18&addressdetails=1',
        );

        final response = await _httpClient.get(
          uri,
          headers: {
            'User-Agent': 'CAMP-App/1.0 (contact: support@camp-moto.app)',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode != 200) {
          return null;
        }

        final map = json.decode(response.body) as Map<String, dynamic>;
        final displayName = (map['display_name'] as String?) ?? '';
        final address = map['address'] as Map<String, dynamic>?;

        String shortName = '';
        if (address != null) {
          shortName = (address['road'] ??
                  address['suburb'] ??
                  address['neighbourhood'] ??
                  address['village'] ??
                  address['town'] ??
                  address['city'] ??
                  address['county'] ??
                  '')
              .toString()
              .trim();
        }

        if (shortName.isEmpty) {
          final parts = displayName.split(',');
          shortName = parts.take(2).join(',').trim();
        }

        final result = PlaceSearchResult(
          name: shortName.isNotEmpty ? shortName : 'Current Location',
          displayName: displayName,
          location: location,
        );

        _reverseCache[cacheKey] = result;
        return result;
      } catch (_) {
        return null;
      }
    });
  }

  /// Sequential queue runner with min 1 second between network requests.
  Future<T> _enqueueRequest<T>(Future<T> Function() action) async {
    while (_activeRequestLock != null) {
      await _activeRequestLock!.future;
    }

    final lock = Completer<void>();
    _activeRequestLock = lock;

    try {
      if (_lastRequestTime != null) {
        final elapsed = DateTime.now().difference(_lastRequestTime!);
        const minGap = Duration(milliseconds: 1000);
        if (elapsed < minGap) {
          await Future<void>.delayed(minGap - elapsed);
        }
      }

      final result = await action();
      _lastRequestTime = DateTime.now();
      return result;
    } finally {
      _activeRequestLock = null;
      lock.complete();
    }
  }
}

/// Fake implementation of [GeocodingService] for testing.
class FakeGeocodingService implements GeocodingService {
  FakeGeocodingService({
    this.searchResults = const [],
    this.reverseResult,
  });

  List<PlaceSearchResult> searchResults;
  PlaceSearchResult? reverseResult;

  @override
  Future<List<PlaceSearchResult>> search(String query) async {
    if (searchResults.isNotEmpty) return searchResults;
    return [
      PlaceSearchResult(
        name: query,
        displayName: '$query, WA',
        location: const LatLng(48.520, -120.650),
      ),
    ];
  }

  @override
  Future<PlaceSearchResult?> reverseGeocode(LatLng location) async {
    return reverseResult ??
        PlaceSearchResult(
          name: 'Cascade Alpine Loop',
          displayName: 'Cascade Alpine Loop, North Cascades, WA',
          location: location,
        );
  }
}
