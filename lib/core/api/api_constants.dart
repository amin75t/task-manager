/// API Constants
/// This file contains all API endpoints and configuration constants
/// Generated from OpenAPI specification at http://task.ziro-one.ir/openapi.json

class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'http://task.ziro-one.ir';

  // API Version
  static const String apiVersion = '1.0.0';

  // Timeout durations (in milliseconds)
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // ============================================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================================

  /// Send OTP to phone number
  /// Method: POST
  /// Body: { "phone": "09123456789" }
  /// Response: { "message": string, "is_new_user": bool, "phone": string, "otp": string }
  static const String sendOtp = '/auth/send-otp';

  /// Verify OTP and get access token
  /// Method: POST
  /// Body: { "phone": "09123456789", "otp": "123456" }
  /// Response: { "access_token": string, "token_type": "bearer", "user_id": int, "phone": string }
  static const String verifyOtp = '/auth/verify-otp';

  // ============================================================================
  // USER ENDPOINTS
  // ============================================================================

  /// Get current user profile
  /// Method: GET
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Response: { "user_id": int, "phone": string, "created_at": string, "updated_at": string }
  static const String currentUser = '/auth/me';

  // ============================================================================
  // TASK ENDPOINTS
  // ============================================================================

  /// Process task text with AI (preview only - does not save)
  /// Method: POST
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Body: { "task_text": string }
  /// Response: { "title": string, "preprocessed_text": string, "original_text": string }
  static const String processTask = '/tasks/process';

  /// Get all tasks for current user
  /// Method: GET
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Response: Array of TaskInDB objects
  static const String tasks = '/tasks';

  /// Create a new task manually
  /// Method: POST
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Body: TaskCreate object
  /// Response: TaskInDB object
  static const String createTask = '/tasks';

  /// Submit and save an AI-processed task
  /// Method: POST
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Body: TaskSubmitProcessed object
  /// Response: TaskInDB object
  static const String submitProcessedTask = '/tasks/submit-processed';

  /// Update a task by ID
  /// Method: PUT
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Path: /tasks/{task_id}
  /// Body: TaskUpdate object (all fields optional)
  /// Response: TaskInDB object
  static String updateTask(int taskId) => '/tasks/$taskId';

  /// Delete a task by ID
  /// Method: DELETE
  /// Headers: { "Authorization": "Bearer {token}" }
  /// Path: /tasks/{task_id}
  /// Response: Success message
  static String deleteTask(int taskId) => '/tasks/$taskId';

  // ============================================================================
  // HEALTH CHECK ENDPOINTS
  // ============================================================================

  /// Welcome endpoint
  /// Method: GET
  /// Public endpoint - no authentication required
  static const String root = '/';

  /// Health check endpoint
  /// Method: GET
  /// Public endpoint - no authentication required
  static const String health = '/health';

  // ============================================================================
  // HEADERS
  // ============================================================================

  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorizationHeader = 'Authorization';

  /// Format: "Bearer {token}"
  static String bearerToken(String token) => 'Bearer $token';

  // ============================================================================
  // PRIORITY LEVELS (from OpenAPI spec)
  // ============================================================================

  static const String priorityUrgent = 'Urgent';
  static const String priorityHigh = 'High';
  static const String priorityMedium = 'Medium';
  static const String priorityLow = 'Low';
}
