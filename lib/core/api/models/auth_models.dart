/// Authentication Models (DTOs)
///
/// Data Transfer Objects for authentication endpoints
/// Based on OpenAPI specification

// ============================================================================
// REQUEST MODELS
// ============================================================================

/// Request model for sending OTP to phone number
class SendOtpRequest {
  final String phone;

  SendOtpRequest({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone};
}

/// Request model for verifying OTP
class VerifyOtpRequest {
  final String phone;
  final String otp;

  VerifyOtpRequest({required this.phone, required this.otp});

  Map<String, dynamic> toJson() => {'phone': phone, 'otp': otp};
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

/// Response model for OTP send request
class OtpSendResponse {
  final String message;
  final bool isNewUser;
  final String phone;
  final String? otp; // Only for testing - remove in production

  OtpSendResponse({
    required this.message,
    required this.isNewUser,
    required this.phone,
    this.otp,
  });

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) {
    return OtpSendResponse(
      message: json['message'] as String,
      isNewUser: json['is_new_user'] as bool,
      phone: json['phone'] as String,
      otp: json['otp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'is_new_user': isNewUser,
    'phone': phone,
    if (otp != null) 'otp': otp,
  };
}

/// Response model for OTP verification (login)
class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int userId;
  final String phone;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.phone,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      userId: json['user_id'] as int,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'user_id': userId,
    'phone': phone,
  };
}

/// User model
class User {
  final int userId;
  final String phone;
  final int dataVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.phone,
    required this.dataVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      phone: json['phone'] as String,
      dataVersion: json['data_version'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'phone': phone,
    'data_version': dataVersion,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}

// ============================================================================
// AUTH STATE MODEL
// ============================================================================

/// Authentication state
enum AuthStatus {
  /// User is authenticated with valid token
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Authentication status is being checked
  checking,
}

/// Complete authentication state
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.errorMessage,
  });

  /// Initial state
  const AuthState.initial()
    : status = AuthStatus.checking,
      user = null,
      token = null,
      errorMessage = null;

  /// Authenticated state
  const AuthState.authenticated({required this.user, required this.token})
    : status = AuthStatus.authenticated,
      errorMessage = null;

  /// Unauthenticated state
  const AuthState.unauthenticated({this.errorMessage})
    : status = AuthStatus.unauthenticated,
      user = null,
      token = null;

  /// Checking state
  const AuthState.checking()
    : status = AuthStatus.checking,
      user = null,
      token = null,
      errorMessage = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isChecking => status == AuthStatus.checking;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
