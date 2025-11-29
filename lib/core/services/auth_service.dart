import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:task_manager/core/api/api_client.dart';
import 'package:task_manager/core/api/models/auth_models.dart';
import 'package:task_manager/core/api/providers/auth_provider.dart';
import 'package:task_manager/core/services/token_service.dart';

/// Authentication Service (Headless)
///
/// A headless, framework-agnostic authentication service that manages:
/// - Authentication state
/// - Login/Logout flow
/// - Token management
/// - User session
///
/// This service is UI-independent and can be used with any state management solution.
/// Listen to [authStateStream] to get real-time auth state updates.
///
/// Features:
/// - Guest mode (use app without login)
/// - Protected features (require login)
/// - Auto token persistence
/// - State broadcasting via Stream
class AuthService {
  final AuthProvider _authProvider;
  final TokenService _tokenService;

  // Stream controller for broadcasting auth state
  final _authStateController = StreamController<AuthState>.broadcast();

  // Current auth state
  AuthState _currentState = const AuthState.initial();

  AuthService(this._authProvider, this._tokenService) {
    _initializeAuthState();
  }

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Stream of authentication state changes
  ///
  /// Listen to this stream to get real-time updates on auth state
  ///
  /// Example:
  /// ```dart
  /// authService.authStateStream.listen((state) {
  ///   if (state.isAuthenticated) {
  ///     // Navigate to home
  ///   } else if (state.isUnauthenticated) {
  ///     // Show login
  ///   }
  /// });
  /// ```
  Stream<AuthState> get authStateStream => _authStateController.stream;

  /// Get current authentication state
  AuthState get currentState => _currentState;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentState.isAuthenticated;

  /// Check if user is unauthenticated
  bool get isUnauthenticated => _currentState.isUnauthenticated;

  /// Get current user (null if not authenticated)
  User? get currentUser => _currentState.user;

  /// Get current token (null if not authenticated)
  String? get currentToken => _currentState.token;

  // ============================================================================
  // AUTHENTICATION FLOW
  // ============================================================================

  /// Initialize authentication state
  ///
  /// Checks if user has valid token and loads user data
  /// Call this on app startup
  Future<void> _initializeAuthState() async {
    print('🔐 [AuthService] Initializing authentication state...');
    _updateState(const AuthState.checking());

    try {
      // Check if token exists
      final token = await _tokenService.getToken();

      if (token == null || token.isEmpty) {
        // No token found - user is not authenticated
        print('🔐 [AuthService] No token found - user is not authenticated');
        _updateState(const AuthState.unauthenticated());
        return;
      }

      print(
        '🔐 [AuthService] Token found - verifying with /auth/me endpoint...',
      );

      // Token exists - try to get user profile
      final user = await _authProvider.getCurrentUser();

      // Successfully got user profile - user is authenticated
      if (kDebugMode) {
        print('🔐 [AuthService] ✅ Authentication successful!');
        print('🔐 [AuthService] User ID: ${user.userId}');
        print('🔐 [AuthService] Phone: ${user.phone}');
        print('🔐 [AuthService] Created At: ${user.createdAt}');
        print('🔐 [AuthService] Updated At: ${user.updatedAt}');
      }
      _updateState(AuthState.authenticated(user: user, token: token));
    } catch (e) {
      // Failed to get user profile - token might be invalid
      print('🔐 [AuthService] ❌ Authentication failed: $e');
      print('🔐 [AuthService] Clearing invalid token...');

      await _tokenService.clearToken();
      _updateState(
        AuthState.unauthenticated(
          errorMessage: 'Session expired. Please login again.',
        ),
      );
    }
  }

  /// Check authentication status manually
  ///
  /// Useful for refreshing auth state
  Future<void> checkAuthStatus() async {
    await _initializeAuthState();
  }

  /// Send OTP to phone number
  ///
  /// Step 1 of login flow
  ///
  /// Returns [OtpSendResponse] with OTP details
  ///
  /// Throws [ApiException] on error
  Future<OtpSendResponse> sendOtp(String phone) async {
    try {
      print('🔐 [AuthService] Sending OTP to: $phone');
      final response = await _authProvider.sendOtp(phone);
      print('🔐 [AuthService] ✅ OTP sent successfully');
      print('🔐 [AuthService] Is new user: ${response.isNewUser}');
      if (response.otp != null) {
        print('🔐 [AuthService] OTP (testing): ${response.otp}');
      }
      return response;
    } catch (e) {
      print('🔐 [AuthService] ❌ Failed to send OTP: $e');
      rethrow;
    }
  }

  /// Verify OTP and complete login
  ///
  /// Step 2 of login flow
  ///
  /// This method:
  /// - Verifies OTP
  /// - Saves token
  /// - Gets user profile
  /// - Updates auth state to authenticated
  ///
  /// Returns [User] object on success
  ///
  /// Throws [ApiException] on error
  Future<User> verifyOtpAndLogin({
    required String phone,
    required String otp,
  }) async {
    try {
      print('🔐 [AuthService] Verifying OTP for phone: $phone');

      // Verify OTP and get token
      final tokenResponse = await _authProvider.verifyOtp(
        phone: phone,
        otp: otp,
      );

      print('🔐 [AuthService] ✅ OTP verified successfully');
      print('🔐 [AuthService] User ID: ${tokenResponse.userId}');
      print('🔐 [AuthService] Token Type: ${tokenResponse.tokenType}');

      // Save token and user info
      await _tokenService.saveAuthData(
        token: tokenResponse.accessToken,
        userId: tokenResponse.userId,
        phone: tokenResponse.phone,
      );

      print('🔐 [AuthService] Token saved - fetching user profile...');

      // Get full user profile
      final user = await _authProvider.getCurrentUser();

      print('🔐 [AuthService] ✅ Login complete!');
      print('🔐 [AuthService] User phone: ${user.phone}');

      // Update state to authenticated
      _updateState(
        AuthState.authenticated(user: user, token: tokenResponse.accessToken),
      );

      return user;
    } catch (e) {
      print('🔐 [AuthService] ❌ Login failed: $e');
      _updateState(AuthState.unauthenticated(errorMessage: e.toString()));
      rethrow;
    }
  }

  /// Logout user
  ///
  /// Clears token and updates state to unauthenticated
  Future<void> logout() async {
    print('🔐 [AuthService] Logging out user...');
    await _tokenService.clearAuthData();
    _updateState(const AuthState.unauthenticated());
    print('🔐 [AuthService] ✅ Logout complete');
  }

  /// Continue as guest (without login)
  ///
  /// Some features can be used without authentication.
  /// This method keeps the state as unauthenticated but allows app usage.
  void continueAsGuest() {
    _updateState(const AuthState.unauthenticated());
  }

  /// Require authentication for protected feature
  ///
  /// Use this before accessing protected features that require login
  ///
  /// Returns true if user is authenticated, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (!authService.requireAuth()) {
  ///   // Show login dialog or navigate to login
  ///   return;
  /// }
  /// // Continue with protected feature
  /// ```
  bool requireAuth() {
    return isAuthenticated;
  }

  /// Execute action that requires authentication
  ///
  /// Headless way to handle protected features
  ///
  /// [action] - The action to execute if authenticated
  /// [onUnauthenticated] - Callback when user is not authenticated (optional)
  ///
  /// Returns result of action if authenticated, null otherwise
  ///
  /// Example:
  /// ```dart
  /// final result = await authService.withAuth<String>(
  ///   action: () async => await taskService.createTask(task),
  ///   onUnauthenticated: () => showLoginDialog(),
  /// );
  /// ```
  Future<T?> withAuth<T>({
    required Future<T> Function() action,
    void Function()? onUnauthenticated,
  }) async {
    if (!isAuthenticated) {
      onUnauthenticated?.call();
      return null;
    }

    return await action();
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  /// Validate phone number
  bool isValidPhone(String phone) => _authProvider.isValidPhoneNumber(phone);

  /// Validate OTP
  bool isValidOtp(String otp) => _authProvider.isValidOtp(otp);

  /// Format phone number for display
  String formatPhone(String phone) => _authProvider.formatPhoneNumber(phone);

  /// Clean phone number (remove formatting)
  String cleanPhone(String phone) => _authProvider.cleanPhoneNumber(phone);

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Update authentication state and broadcast to listeners
  void _updateState(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
