import 'package:flutter/foundation.dart';
import '../../../core/data/app_repositories.dart';
import '../../../core/data/profile_repository.dart';
import '../../../core/data/profile_repository_local.dart';
import '../../auth/controllers/auth_controller.dart';
import '../domain/user_profile_model.dart';

/// Single source of truth for the rider's profile information.
/// Persisted through [ProfileRepository].
class ProfileController extends ChangeNotifier {
  ProfileController({ProfileRepository? repository})
      : _repository = repository ?? AppRepositories.instance.profileRepository;

  static ProfileController instance = ProfileController();

  ProfileRepository _repository;

  @visibleForTesting
  set repository(ProfileRepository repo) => _repository = repo;

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

  /// Update profile attributes and persist to [ProfileRepository].
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
  Future<void> flush() => _repository.flush();

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
    _repository = AppRepositories.instance.profileRepository;
    notifyListeners();
  }

  /// Load profile from repository.
  Future<void> load([dynamic source]) async {
    final repo = resolveProfileRepository(source, _repository);
    if (source != null) {
      _repository = repo;
    }
    try {
      final profile = await repo.loadProfile();
      if (profile != null) {
        _fullName = profile.fullName;
        _username = profile.username;
        _email = profile.email;
        _phone = profile.phone;
        _homeCity = profile.homeCity;
        _dob = profile.dob;
        _avatarPath = profile.avatarPath;
        _ridingTier = profile.ridingTier;
        _experienceIndex = profile.experienceIndex;
        _ridingStyles = profile.ridingStyles;
        _unitIndex = profile.unitIndex;
        _emergencyContactName = profile.emergencyContactName;
        _emergencyContactRelation = profile.emergencyContactRelation;
        _emergencyContactPhone = profile.emergencyContactPhone;
        _bloodGroup = profile.bloodGroup;
        notifyListeners();
      }
    } catch (_) {
      // Gracefully fall back to defaults
    }
  }

  /// Save profile to repository.
  Future<void> save([dynamic source]) async {
    final repo = resolveProfileRepository(source, _repository);
    final profile = UserProfile(
      fullName: _fullName,
      username: _username,
      email: _email,
      phone: _phone,
      homeCity: _homeCity,
      dob: _dob,
      avatarPath: _avatarPath,
      ridingTier: _ridingTier,
      experienceIndex: _experienceIndex,
      ridingStyles: _ridingStyles,
      unitIndex: _unitIndex,
      emergencyContactName: _emergencyContactName,
      emergencyContactRelation: _emergencyContactRelation,
      emergencyContactPhone: _emergencyContactPhone,
      bloodGroup: _bloodGroup,
    );
    await repo.saveProfile(profile);
  }
}
