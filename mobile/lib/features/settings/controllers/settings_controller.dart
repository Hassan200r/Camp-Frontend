import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../domain/units_system.dart';

/// Central state controller managing application settings:
/// Units (Metric/Imperial), Notifications, Privacy & Data Sharing, Offline Maps cache, and Language.
///
/// Follows the same reactive ChangeNotifier singleton pattern as [ActiveBikeController].
class SettingsController extends ChangeNotifier {
  SettingsController._();

  /// Shared singleton instance across the application.
  static final SettingsController instance = SettingsController._();

  UnitsSystem _units = UnitsSystem.metric;
  bool _notificationsEnabled = true;
  bool _privacySharingEnabled = true;
  double _cachedPacksSizeGb = 14.2;
  String _cachedPacksSubtitle = 'Cascades & Alps Route Packs';
  double _localCacheSizeGb = 1.4;
  String _language = 'English';

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

  /// Reset all preferences to factory defaults (useful for tests).
  void reset() {
    _units = UnitsSystem.metric;
    _notificationsEnabled = true;
    _privacySharingEnabled = true;
    _cachedPacksSizeGb = 14.2;
    _cachedPacksSubtitle = 'Cascades & Alps Route Packs';
    _localCacheSizeGb = 1.4;
    _language = 'English';
    notifyListeners();
  }

  /// Reset in-memory preferences for testing.
  void resetForTesting() {
    reset();
  }

  /// Await completion of all pending storage writes.
  Future<void> flush() => LocalStore.instance.flush();

  /// Load user settings from persistent store.
  Future<void> load([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final isFirst = await localStore.isFirstRun();

    if (isFirst) {
      _units = UnitsSystem.metric;
      _notificationsEnabled = true;
      _privacySharingEnabled = true;
      await save(localStore);
      return;
    }

    try {
      final json = await localStore.readJson(LocalStore.keySettings);
      if (json == null || json is! Map) {
        // Fall back to defaults without crashing
        _units = UnitsSystem.metric;
        _notificationsEnabled = true;
        _privacySharingEnabled = true;
        notifyListeners();
        return;
      }

      final schemaVer = await localStore.getSchemaVersion();
      if (schemaVer == null || schemaVer > LocalStore.currentSchemaVersion) {
        _units = UnitsSystem.metric;
        _notificationsEnabled = true;
        _privacySharingEnabled = true;
        notifyListeners();
        return;
      }

      final map = json.cast<String, dynamic>();
      final unitsStr = map['units'] as String?;
      if (unitsStr == 'imperial') {
        _units = UnitsSystem.imperial;
      } else {
        _units = UnitsSystem.metric;
      }

      _notificationsEnabled = map['notificationsEnabled'] as bool? ?? true;
      _privacySharingEnabled = map['privacySharingEnabled'] as bool? ?? true;
      notifyListeners();
    } catch (_) {
      // Fallback on corrupt data
      _units = UnitsSystem.metric;
      _notificationsEnabled = true;
      _privacySharingEnabled = true;
      notifyListeners();
    }
  }

  /// Persist user settings to persistent store.
  Future<void> save([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    try {
      await localStore.writeJson(LocalStore.keySettings, {
        'units': _units.name,
        'notificationsEnabled': _notificationsEnabled,
        'privacySharingEnabled': _privacySharingEnabled,
      });
    } catch (_) {
      // Ignore background write errors
    }
  }
}
