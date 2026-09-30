import 'package:flutter/foundation.dart';

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
  }

  /// Toggle or update the push notification preference.
  void setNotificationsEnabled(bool enabled) {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  /// Toggle or update ride telemetry anonymization and sharing preference.
  void setPrivacySharingEnabled(bool enabled) {
    if (_privacySharingEnabled == enabled) return;
    _privacySharingEnabled = enabled;
    notifyListeners();
  }

  void togglePrivacySharing() {
    _privacySharingEnabled = !_privacySharingEnabled;
    notifyListeners();
  }

  /// Clear temporary tile and telemetry cache, releasing local device space.
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
}
