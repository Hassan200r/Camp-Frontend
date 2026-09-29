import 'package:flutter/foundation.dart';
import '../domain/auth_state.dart';
import '../domain/user_model.dart';

/// Controller handling Rider Authentication, Session State, and Biometric Handshakes
class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  AuthState _state = const AuthState();
  AuthState get state => _state;

  RiderUser? get currentUser => _state.currentUser;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading => _state.isLoading;

  /// Display name of the active rider (falls back gracefully to default)
  String get riderDisplayName {
    final name = currentUser?.name.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Elena Vance';
  }

  /// First name of the active rider for avatar circle badges
  String get riderFirstName {
    final name = riderDisplayName;
    if (name.contains(' ')) return name.split(' ').first;
    return name;
  }

  /// Calculate password strength from 0 (none) to 4 (maximum)
  int calculateStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 9) strength++;
    if (RegExp(r'[0-9]').hasMatch(password) || RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    }
    return strength.clamp(1, 4);
  }

  /// Format an input into a clean rider display name
  String _parseRiderName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Elena Vance';

    // If it's an email address like elena.vance@camp.io or alex_henderson@bmw.com
    if (trimmed.contains('@')) {
      final localPart = trimmed.split('@').first;
      final parts = localPart.split(RegExp(r'[._\-]'));
      final formatted = parts
          .where((p) => p.isNotEmpty)
          .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
          .join(' ');
      return formatted.isNotEmpty ? formatted : 'Rider';
    }

    // If it's already a full name or single username
    return trimmed;
  }

  /// Sign In with Rider ID or Email
  Future<bool> signIn({
    required String riderIdOrEmail,
    required String password,
  }) async {
    _state = _state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );
    notifyListeners();

    // Simulate network telemetry authentication handshake
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final trimmedInput = riderIdOrEmail.trim();
    if (trimmedInput.isEmpty || password.isEmpty) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter your Rider ID / Email and password.',
      );
      notifyListeners();
      return false;
    }

    final parsedName = _parseRiderName(trimmedInput);

    final user = RiderUser(
      id: trimmedInput.contains('@') ? 'RIDER-${trimmedInput.split('@').first.toUpperCase()}' : trimmedInput,
      name: parsedName,
      email: trimmedInput.contains('@') ? trimmedInput : '$trimmedInput@camp.io',
      phone: '+1 (555) 019–2834',
      telemetryActive: true,
      biometricEnabled: true,
      memberSince: DateTime.now().subtract(const Duration(days: 90)),
    );

    _state = _state.copyWith(
      status: AuthStatus.authenticated,
      currentUser: user,
      errorMessage: null,
    );
    notifyListeners();
    return true;
  }

  /// Sign Up / Register New Rider Profile
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _state = _state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1100));

    if (fullName.trim().isEmpty) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter your full name.',
      );
      notifyListeners();
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter a valid email address.',
      );
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Password must be at least 6 characters.',
      );
      notifyListeners();
      return false;
    }

    final newUser = RiderUser(
      id: 'RIDER-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: fullName.trim(),
      email: email.trim(),
      phone: phone.trim().isEmpty ? '+1 (555) 019–2834' : phone.trim(),
      callSign: 'Adventure Pilot',
      helmetTokenId: 'TOKEN-CAMP-${DateTime.now().millisecondsSinceEpoch % 1000}',
      telemetryActive: true,
      biometricEnabled: true,
      memberSince: DateTime.now(),
    );

    _state = _state.copyWith(
      status: AuthStatus.authenticated,
      currentUser: newUser,
      errorMessage: null,
    );
    notifyListeners();
    return true;
  }

  /// Sign In with Biometric / Helmet Token
  Future<bool> signInWithBiometric() async {
    _state = _state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    _state = _state.copyWith(
      status: AuthStatus.authenticated,
      currentUser: RiderUser.defaultRider,
      activeHelmetToken: 'SCHUBERTH-C5-BT-ACTIVE',
      errorMessage: null,
    );
    notifyListeners();
    return true;
  }

  /// Request Password Reset link
  Future<bool> requestPasswordReset(String email) async {
    _state = _state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    _state = _state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
    notifyListeners();
    return true;
  }

  /// Sign Out current rider
  void signOut() {
    _state = const AuthState(status: AuthStatus.unauthenticated);
    notifyListeners();
  }
}
