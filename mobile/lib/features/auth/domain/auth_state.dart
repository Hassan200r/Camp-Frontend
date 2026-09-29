import 'user_model.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.currentUser,
    this.errorMessage,
    this.activeHelmetToken,
  });

  final AuthStatus status;
  final RiderUser? currentUser;
  final String? errorMessage;
  final String? activeHelmetToken;

  bool get isAuthenticated => status == AuthStatus.authenticated && currentUser != null;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    RiderUser? currentUser,
    String? errorMessage,
    String? activeHelmetToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
      activeHelmetToken: activeHelmetToken ?? this.activeHelmetToken,
    );
  }
}
