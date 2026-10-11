import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper around [SharedPreferences] providing typed JSON storage,
/// schema versioning, and first-run detection for CAMP offline persistence.
class LocalStore {
  LocalStore([this._prefs]);

  static LocalStore instance = LocalStore();

  SharedPreferences? _prefs;

  static const String schemaVersionKey = 'camp_schema_version';
  static const int currentSchemaVersion = 1;

  static const String keyBikes = 'camp_bikes';
  static const String keyActiveBikeId = 'camp_active_bike_id';
  static const String keySettings = 'camp_settings';
  static const String keyPostRideReports = 'camp_post_ride_reports';
  static const String keyTripBudget = 'camp_trip_budget';
  static const String keyTripExpenses = 'camp_trip_expenses';
  static const String keyFirstRunCompleted = 'camp_first_run_completed';

  Future<SharedPreferences> get prefs async {
    final p = _prefs;
    if (p != null) return p;
    final resolved = await SharedPreferences.getInstance();
    _prefs = resolved;
    return resolved;
  }

  /// Initialize local store.
  Future<void> init([SharedPreferences? customPrefs]) async {
    _prefs = customPrefs ?? await SharedPreferences.getInstance();
  }

  /// Reset internal preferences reference for test harnesses.
  void resetForTesting([SharedPreferences? mockPrefs]) {
    _prefs = mockPrefs;
  }

  /// Read raw string value for [key].
  Future<String?> readString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  /// Write raw string [value] for [key].
  Future<bool> writeString(String key, String value) async {
    final p = await prefs;
    return p.setString(key, value);
  }

  /// Read and parse JSON from string stored at [key].
  /// Returns null if key does not exist or if content is corrupted.
  Future<dynamic> readJson(String key) async {
    try {
      final raw = await readString(key);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw);
    } catch (_) {
      // Gracefully handle malformed or corrupted JSON without crashing
      return null;
    }
  }

  /// Encode [value] to JSON string and store at [key].
  Future<bool> writeJson(String key, dynamic value) async {
    final encoded = jsonEncode(value);
    return writeString(key, encoded);
  }

  /// Remove entry by [key].
  Future<bool> remove(String key) async {
    final p = await prefs;
    return p.remove(key);
  }

  /// Check whether this is the application's first run.
  Future<bool> isFirstRun() async {
    final p = await prefs;
    return !p.containsKey(keyFirstRunCompleted) &&
        !p.containsKey(schemaVersionKey);
  }

  /// Mark first-run seeding as completed.
  Future<void> markFirstRunCompleted() async {
    final p = await prefs;
    await p.setBool(keyFirstRunCompleted, true);
    await p.setInt(schemaVersionKey, currentSchemaVersion);
  }

  /// Read stored schema version, if present.
  Future<int?> getSchemaVersion() async {
    final p = await prefs;
    return p.getInt(schemaVersionKey);
  }

  /// Write schema version integer.
  Future<bool> setSchemaVersion(int version) async {
    final p = await prefs;
    return p.setInt(schemaVersionKey, version);
  }

  /// Clear all stored keys in [SharedPreferences].
  Future<bool> clear() async {
    final p = await prefs;
    return p.clear();
  }
}
