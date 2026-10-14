import 'package:flutter/foundation.dart';
import '../../../core/storage/local_store.dart';
import '../../auth/controllers/auth_controller.dart';

/// Single source of truth for the rider's profile information.
/// Persisted locally via [LocalStore].
class ProfileController extends ChangeNotifier {
  ProfileController._();

  static final ProfileController instance = ProfileController._();

  String? _fullName;
  String? _username;
  String? _email;
  String? _phone;
  String? _homeCity;
  String? _dob;
  String? _avatarPath;
  String _ridingTier = 'ADV PRO';
  int _experienceIndex = 2; // 0=Beginner, 1=Intermediate, 2=Advanced
  Set<String> _ridingStyles = {'Touring'};
  int _unitIndex = 0; // 0=Metric, 1=Imperial

  // Emergency contact fields
  String? _emergencyContactName;
  String? _emergencyContactRelation;
  String? _emergencyContactPhone;
  String _bloodGroup = 'O+ (Universal Donor)';

  // ── Getters ────────────────────────────────────────────────────────────────
  String get fullName {
    if (_fullName != null && _fullName!.trim().isNotEmpty) {
      return _fullName!.trim();
    }
    final authName = AuthController.instance.currentUser?.name.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName;
    }
    return AuthController.instance.riderDisplayName;
  }

  String get firstName {
    final name = fullName;
    if (name.contains(' ')) return name.split(' ').first;
    return name;
  }

  String get username => _username ?? '@rider';

  String get email {
    if (_email != null && _email!.trim().isNotEmpty) {
      return _email!.trim();
    }
    return AuthController.instance.currentUser?.email ?? 'rider@camp.io';
  }

  String get phone => _phone ?? (AuthController.instance.currentUser?.phone ?? '');
  String get homeCity => _homeCity ?? '';
  String get dob => _dob ?? '';
  String? get avatarPath => _avatarPath;
  String get ridingTier => _ridingTier;
  int get experienceIndex => _experienceIndex;
  Set<String> get ridingStyles => Set.unmodifiable(_ridingStyles);
  int get unitIndex => _unitIndex;

  String get emergencyContactName => _emergencyContactName ?? '';
  String get emergencyContactRelation => _emergencyContactRelation ?? 'Emergency Contact';
  String get emergencyContactPhone => _emergencyContactPhone ?? '';
  String get bloodGroup => _bloodGroup;

  /// Update profile attributes and persist to [LocalStore].
  void updateProfile({
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? homeCity,
    String? dob,
    String? avatarPath,
    String? ridingTier,
    int? experienceIndex,
    Set<String>? ridingStyles,
    int? unitIndex,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
    String? bloodGroup,
  }) {
    if (fullName != null) _fullName = fullName;
    if (username != null) _username = username;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (homeCity != null) _homeCity = homeCity;
    if (dob != null) _dob = dob;
    if (avatarPath != null) _avatarPath = avatarPath;
    if (ridingTier != null) _ridingTier = ridingTier;
    if (experienceIndex != null) _experienceIndex = experienceIndex;
    if (ridingStyles != null) _ridingStyles = Set.from(ridingStyles);
    if (unitIndex != null) _unitIndex = unitIndex;
    if (emergencyContactName != null) _emergencyContactName = emergencyContactName;
    if (emergencyContactRelation != null) _emergencyContactRelation = emergencyContactRelation;
    if (emergencyContactPhone != null) _emergencyContactPhone = emergencyContactPhone;
    if (bloodGroup != null) _bloodGroup = bloodGroup;

    notifyListeners();
    save();
  }

  /// Update only the avatar file path and persist.
  void setAvatarPath(String path) {
    _avatarPath = path;
    notifyListeners();
    save();
  }

  /// Await completion of all pending storage writes.
  Future<void> flush() => LocalStore.instance.flush();

  /// Reset in-memory state for testing.
  @visibleForTesting
  void resetForTesting() {
    _fullName = null;
    _username = null;
    _email = null;
    _phone = null;
    _homeCity = null;
    _dob = null;
    _avatarPath = null;
    _ridingTier = 'ADV PRO';
    _experienceIndex = 2;
    _ridingStyles = {'Touring'};
    _unitIndex = 0;
    _emergencyContactName = null;
    _emergencyContactRelation = null;
    _emergencyContactPhone = null;
    _bloodGroup = 'O+ (Universal Donor)';
    notifyListeners();
  }

  /// Load profile from storage.
  Future<void> load([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    try {
      final json = await localStore.readJson(LocalStore.keyProfile);
      if (json is Map<String, dynamic>) {
        _fullName = json['fullName'] as String?;
        _username = json['username'] as String?;
        _email = json['email'] as String?;
        _phone = json['phone'] as String?;
        _homeCity = json['homeCity'] as String?;
        _dob = json['dob'] as String?;
        _avatarPath = json['avatarPath'] as String?;
        _ridingTier = json['ridingTier'] as String? ?? 'ADV PRO';
        _experienceIndex = (json['experienceIndex'] as num?)?.toInt() ?? 2;
        if (json['ridingStyles'] is List) {
          _ridingStyles = (json['ridingStyles'] as List).cast<String>().toSet();
        }
        _unitIndex = (json['unitIndex'] as num?)?.toInt() ?? 0;
        _emergencyContactName = json['emergencyContactName'] as String?;
        _emergencyContactRelation = json['emergencyContactRelation'] as String?;
        _emergencyContactPhone = json['emergencyContactPhone'] as String?;
        _bloodGroup = json['bloodGroup'] as String? ?? 'O+ (Universal Donor)';
        notifyListeners();
      }
    } catch (_) {
      // Gracefully fall back to defaults
    }
  }

  /// Save profile to storage.
  Future<void> save([LocalStore? store]) async {
    final localStore = store ?? LocalStore.instance;
    final map = <String, dynamic>{
      'fullName': _fullName,
      'username': _username,
      'email': _email,
      'phone': _phone,
      'homeCity': _homeCity,
      'dob': _dob,
      'avatarPath': _avatarPath,
      'ridingTier': _ridingTier,
      'experienceIndex': _experienceIndex,
      'ridingStyles': _ridingStyles.toList(),
      'unitIndex': _unitIndex,
      'emergencyContactName': _emergencyContactName,
      'emergencyContactRelation': _emergencyContactRelation,
      'emergencyContactPhone': _emergencyContactPhone,
      'bloodGroup': _bloodGroup,
    };
    await localStore.writeJson(LocalStore.keyProfile, map);
  }
}
