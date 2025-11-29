# Authentication System - Usage Examples

## Overview

This is a **headless, customizable authentication system** that supports:
- ✅ Guest mode (use features without login)
- ✅ Protected features (require login)
- ✅ OTP-based authentication
- ✅ Automatic token management
- ✅ Real-time auth state updates via Stream
- ✅ Framework-agnostic (works with any UI)

---

## Quick Start

### 1. Get AuthService Instance

```dart
import 'package:task_manager/locator.dart';
import 'package:task_manager/core/services/auth_service.dart';

final authService = locator<AuthService>();
```

### 2. Listen to Auth State Changes

```dart
// In your widget's initState or StatefulWidget
authService.authStateStream.listen((state) {
  if (state.isAuthenticated) {
    print('User is logged in: ${state.user?.phone}');
    // Navigate to home or show authenticated UI
  } else if (state.isUnauthenticated) {
    print('User is not logged in');
    // Show login button or guest UI
  } else if (state.isChecking) {
    print('Checking authentication status...');
    // Show loading spinner
  }
});
```

### 3. Check Current Auth Status

```dart
// Check if user is logged in
if (authService.isAuthenticated) {
  print('User is logged in');
  print('Phone: ${authService.currentUser?.phone}');
} else {
  print('User is not logged in');
}
```

---

## Login Flow (OTP Authentication)

### Step 1: Send OTP

```dart
Future<void> sendOtp(String phoneNumber) async {
  try {
    // Validate phone number first
    if (!authService.isValidPhone(phoneNumber)) {
      print('Invalid phone number');
      return;
    }

    // Clean phone number (remove spaces, etc.)
    final cleanPhone = authService.cleanPhone(phoneNumber);

    // Send OTP
    final response = await authService.sendOtp(cleanPhone);

    print('OTP sent successfully!');
    print('Is new user: ${response.isNewUser}');
    print('OTP (for testing): ${response.otp}'); // Remove in production

    // Navigate to OTP verification screen
  } catch (e) {
    print('Error sending OTP: $e');
  }
}
```

### Step 2: Verify OTP and Login

```dart
Future<void> verifyOtp(String phoneNumber, String otp) async {
  try {
    // Validate OTP format
    if (!authService.isValidOtp(otp)) {
      print('Invalid OTP format');
      return;
    }

    // Verify OTP and login
    final user = await authService.verifyOtpAndLogin(
      phone: phoneNumber,
      otp: otp,
    );

    print('Login successful!');
    print('User ID: ${user.userId}');
    print('Phone: ${user.phone}');

    // Auth state will automatically update
    // Navigate to home screen
  } catch (e) {
    print('Login failed: $e');
  }
}
```

---

## Guest Mode

Allow users to use the app without login:

```dart
void continueAsGuest() {
  authService.continueAsGuest();
  // Navigate to home screen with limited features
}
```

---

## Protected Features

### Method 1: Using `requireAuth()`

```dart
void createTask() {
  if (!authService.requireAuth()) {
    // Show login dialog
    showLoginDialog();
    return;
  }

  // User is authenticated - proceed with creating task
  // Task will be saved to server
}
```

### Method 2: Using `withAuth()` (Headless)

```dart
Future<void> createTask(Task task) async {
  final result = await authService.withAuth<Task>(
    action: () async {
      // This code only runs if user is authenticated
      return await taskApi.createTask(task);
    },
    onUnauthenticated: () {
      // Show login dialog or notification
      print('Please login to save tasks to server');
    },
  );

  if (result != null) {
    print('Task created successfully');
  }
}
```

---

## Logout

```dart
Future<void> logout() async {
  await authService.logout();
  print('Logged out successfully');
  // Navigate to login or home screen
}
```

---

## UI Integration Examples

### Example 1: StreamBuilder (Flutter)

```dart
class MyHomePage extends StatelessWidget {
  final authService = locator<AuthService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: authService.authStateStream,
      initialData: authService.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.isChecking) {
          return CircularProgressIndicator();
        }

        if (state.isAuthenticated) {
          return AuthenticatedHomePage(user: state.user!);
        }

        return GuestHomePage();
      },
    );
  }
}
```

### Example 2: Conditional Features

```dart
class TaskScreen extends StatelessWidget {
  final authService = locator<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Always visible
        Text('Tasks'),

        // Only visible when logged in
        if (authService.isAuthenticated)
          ElevatedButton(
            onPressed: () => syncTasksToServer(),
            child: Text('Sync to Cloud'),
          ),

        // Show login button if not authenticated
        if (!authService.isAuthenticated)
          ElevatedButton(
            onPressed: () => showLoginDialog(context),
            child: Text('Login to Sync'),
          ),
      ],
    );
  }
}
```

### Example 3: Login Dialog

```dart
Future<void> showLoginDialog(BuildContext context) async {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  bool otpSent = false;

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(otpSent ? 'Enter OTP' : 'Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!otpSent)
              TextField(
                controller: phoneController,
                decoration: InputDecoration(hintText: '09123456789'),
                keyboardType: TextInputType.phone,
              ),
            if (otpSent)
              TextField(
                controller: otpController,
                decoration: InputDecoration(hintText: '123456'),
                keyboardType: TextInputType.number,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!otpSent) {
                // Send OTP
                await authService.sendOtp(phoneController.text);
                setState(() => otpSent = true);
              } else {
                // Verify OTP
                await authService.verifyOtpAndLogin(
                  phone: phoneController.text,
                  otp: otpController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text(otpSent ? 'Verify' : 'Send OTP'),
          ),
        ],
      ),
    ),
  );
}
```

---

## Advanced Features

### Check Auth Status on App Start

```dart
// In main.dart or app initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();

  // Auth state is automatically checked during initialization
  // You can also manually check:
  // await locator<AuthService>().checkAuthStatus();

  runApp(MyApp());
}
```

### Handle Session Expiry

The auth interceptor automatically detects 401 errors and clears the token.
The auth state will automatically update to unauthenticated.

```dart
authService.authStateStream.listen((state) {
  if (state.isUnauthenticated && state.errorMessage != null) {
    print('Session expired: ${state.errorMessage}');
    // Show login dialog
  }
});
```

---

## Validation Helpers

```dart
// Validate phone number (Iranian format)
bool isValid = authService.isValidPhone('09123456789'); // true
isValid = authService.isValidPhone('123'); // false

// Validate OTP (6 digits)
bool isValid = authService.isValidOtp('123456'); // true
isValid = authService.isValidOtp('12'); // false

// Format phone for display
String formatted = authService.formatPhone('09123456789');
// Output: "0912 345 6789"

// Clean phone number (remove spaces and special characters)
String clean = authService.cleanPhone('0912 345 6789');
// Output: "09123456789"
```

---

## Best Practices

1. ✅ **Always check auth status before calling protected APIs**
2. ✅ **Use `withAuth()` for clean, headless auth checks**
3. ✅ **Listen to `authStateStream` for real-time updates**
4. ✅ **Validate phone numbers and OTPs before sending**
5. ✅ **Handle errors gracefully with try-catch**
6. ✅ **Show clear UI feedback for login/logout actions**
7. ✅ **Support guest mode for non-critical features**

---

## Architecture Benefits

### Headless Design
- ✅ No UI dependencies
- ✅ Works with any state management (BLoC, Provider, Riverpod, etc.)
- ✅ Easy to test
- ✅ Highly customizable

### Separation of Concerns
- `AuthProvider` - API calls only
- `AuthService` - Business logic and state management
- `TokenService` - Token persistence only
- `ApiClient` - HTTP client configuration

### Flexibility
- ✅ Guest mode support
- ✅ Protected feature handling
- ✅ Real-time state updates
- ✅ Easy to extend for more auth methods

---

## Troubleshooting

**Q: Auth state not updating?**
- Make sure you're listening to `authStateStream`
- Check if services are registered in `locator.dart`

**Q: 401 Unauthorized errors?**
- Token might be expired - user will be auto-logged out
- Listen to auth state stream for session expiry

**Q: OTP not sending?**
- Check phone number format (should be 09XXXXXXXXX)
- Check network connection
- Check API logs in console

**Q: How to force login for entire app?**
```dart
// In your main app widget
if (!authService.isAuthenticated) {
  return LoginScreen();
}
return HomeScreen();
```
