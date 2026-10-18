import 'package:flutter/foundation.dart';

import '../../../core/data/app_repositories.dart';
import '../../../core/data/settings_repository.dart';
import '../../../core/data/settings_repository_local.dart';
import '../domain/app_settings.dart';
import '../domain/units_system.dart';

/// Central state controller managing application settings:
/// Units (Metric/Imperial), Notifications, Privacy & Data Sharing, Offline Maps cache, and Language.
///
/// Follows the same reactive ChangeNotifier singleton pattern as [ActiveBikeController].
class SettingsController extends ChangeNotifier {
  SettingsController({SettingsRepository? repository})
      : _repository = repository ?? AppRepositories.instance.settingsRepository;

  /// Shared singleton instance across the application.
  static SettingsController instance = SettingsController();

  SettingsRepository _repository;

  @visibleForTesting
  SettingsRepository get repository => _repository;

  @visibleForTesting
  set repository(SettingsRepository repo) => _repository = repo;

  UnitsSystem _units = UnitsSystem.metric;
  bool _notificationsEnabled = true;
  bool _privacySharingEnabled = true;
  double _cachedPacksSizeGb = 14.2;
  String _cachedPacksSubtitle = 'Cascades & Alps Route Packs';
  double _localCacheSizeGb = 1.4;
  String _language = 'English';
  String _emergencyNumber = '1122';

  // ── Getters ────────────────────────────────────────────────────────────────
  UnitsSystem get units => _units;
  bool get isMetric => _units == UnitsSystem.metric;
  bool get isImperial => _units == UnitsSystem.imperial;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get privacySharingEnabled => _privacySharingEnabled;
  double get cachedPacksSizeGb => _cachedPacksSizeGb;
  String get cachedPacksSubtitle => _cachedPacksSubtitle;
  double get localCacheSizeGb => _localCacheSizeGb;
  String get language => _language;
  String get emergencyNumber => _emergencyNumber;

  /// Human-readable representation of local cache size
  String get localCacheDisplay {
    if (_localCacheSizeGb <= 0.0) return '0 B';
    return '${_localCacheSizeGb.toStringAsFixed(1)} GB';
  }

  // ── Modifiers ─────────────────────────────────────────────────────────────

  /// Update the active measurement unit system.
  void setUnits(UnitsSystem units) {
    if (_units == units) return;
    _units = units;
    notifyListeners();
    save();
  }

  /// Toggle or update the push notification preference.
  void setNotificationsEnabled(bool enabled) {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
    save();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    save();
  }

  /// Toggle or update ride telemetry anonymization and sharing preference.
  void setPrivacySharingEnabled(bool enabled) {
    if (_privacySharingEnabled == enabled) return;
    _privacySharingEnabled = enabled;
    notifyListeners();
    save();
  }

  void togglePrivacySharing() {
    _privacySharingEnabled = !_privacySharingEnabled;
    notifyListeners();
    save();
  }

  /// Clear temporary tile and telemetry cache, releasing local device space.
  /// NOTE: This only clears map/tile cache, never garage, reports, or settings.
  void clearLocalCache() {
    _localCacheSizeGb = 0.0;
    notifyListeners();
  }

  /// Update the user display language.
  void setLanguage(String language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  /// Update the emergency rescue dispatch number.
  void setEmergencyNumber(String number) {
    final clean = number.trim();
    if (clean.isEmpty || _emergencyNumber == clean) return;
    _emergencyNumber = clean;
    notifyListeners();
    save();
  }

  /// Reset all preferences to factory defaults (useful for tests).
  void reset() {
    _units = UnitsSystem.metric;
    _notificationsEnabled = true;
    _privacySharingEnabled = true;
    _cachedPacksSizeGb = 14.2;
    _cachedPacksSubtitle = 'Cascades & Alps Route Packs';
    _localCacheSizeGb = 1.4;
    _language = 'English';
    _emergencyNumber = '1122';
    notifyListeners();
  }

  /// Reset in-memory preferences for testing.
  void resetForTesting() {
    reset();
    _repository = AppRepositories.instance.settingsRepository;
  }

  /// Await completion of all pending storage writes.
  Future<void> flush() => _repository.flush();

  /// Load user settings from repository.
  Future<void> load([dynamic source]) async {
    final repo = resolveSettingsRepository(source, _repository);
    if (source != null) {
      _repository = repo;
    }
    try {
      final settings = await repo.loadSettings();
      _units = settings.units;
      _notificationsEnabled = settings.notificationsEnabled;
      _privacySharingEnabled = settings.privacySharingEnabled;
      _emergencyNumber = settings.emergencyNumber;
      notifyListeners();
    } catch (_) {
      _units = UnitsSystem.metric;
      _notificationsEnabled = true;
      _privacySharingEnabled = true;
      _emergencyNumber = '1122';
      notifyListeners();
    }
  }

  /// Persist user settings to repository.
  Future<void> save([dynamic source]) async {
    final repo = resolveSettingsRepository(source, _repository);
    try {
      final settings = AppSettings(
        units: _units,
        notificationsEnabled: _notificationsEnabled,
        privacySharingEnabled: _privacySharingEnabled,
        emergencyNumber: _emergencyNumber,
      );
      await repo.saveSettings(settings);
    } catch (_) {
      // Ignore background write errors
    }
  }
}
