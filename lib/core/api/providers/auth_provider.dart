import 'package:task_manager/core/api/api_client.dart';
import 'package:task_manager/core/api/api_constants.dart';
import 'package:task_manager/core/api/models/auth_models.dart';

/// Authentication API Provider
///
/// Handles all authentication-related API calls
/// - Send OTP
/// - Verify OTP
/// - Get current user profile
/// - Token management
class AuthProvider {
  final ApiClient _apiClient;

  AuthProvider(this._apiClient);

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Send OTP to phone number
  ///
  /// This endpoint:
  /// - Creates a new user if phone doesn't exist
  /// - Sends OTP via SMS to the phone number
  /// - Returns OTP in response (for testing only)
  ///
  /// [phone] - Phone number in format like "09123456789"
  ///
  /// Returns [OtpSendResponse] with message, isNewUser flag, and OTP
  ///
  /// Throws [ApiException] on error
  Future<OtpSendResponse> sendOtp(String phone) async {
    try {
      final request = SendOtpRequest(phone: phone);

      final response = await _apiClient.post(
        ApiConstants.sendOtp,
        data: request.toJson(),
      );

      return OtpSendResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP and login
  ///
  /// Verifies the OTP code and returns JWT access token
  ///
  /// [phone] - Phone number
  /// [otp] - 6-digit OTP code
  ///
  /// Returns [TokenResponse] with access token and user info
  ///
  /// Throws [ApiException] on error
  Future<TokenResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final request = VerifyOtpRequest(phone: phone, otp: otp);

      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: request.toJson(),
      );

      return TokenResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current authenticated user profile
  ///
  /// Requires authentication (JWT token in header)
  ///
  /// Returns [User] object with profile information
  ///
  /// Throws [ApiException] on error (401 if not authenticated)
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.currentUser);

      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if phone number is valid
  ///
  /// Basic validation for Iranian phone numbers
  /// Format: 09XXXXXXXXX (11 digits)
  bool isValidPhoneNumber(String phone) {
    // Remove any whitespace
    phone = phone.trim();

    // Check length (Iranian mobile: 11 digits starting with 09)
    if (phone.length != 11) return false;

    // Check if starts with 09
    if (!phone.startsWith('09')) return false;

    // Check if all characters are digits
    return RegExp(r'^\d+$').hasMatch(phone);
  }

  /// Check if OTP is valid format
  ///
  /// OTP should be exactly 6 digits
  bool isValidOtp(String otp) {
    // Remove any whitespace
    otp = otp.trim();

    // Check length
    if (otp.length != 6) return false;

    // Check if all characters are digits
    return RegExp(r'^\d+$').hasMatch(otp);
  }

  /// Format phone number for display
  ///
  /// Converts "09123456789" to "0912 345 6789"
  String formatPhoneNumber(String phone) {
    if (phone.length != 11) return phone;

    return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
  }

  /// Clean phone number (remove spaces and special characters)
  ///
  /// Useful for user input
  String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
}
