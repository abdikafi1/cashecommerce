import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController extends GetxController {
  final RxString userId = ''.obs;
  final RxString userRole = 'user'.obs;
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;

  // Register method with feedback (with role selection)
  Future<bool> register(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/register'),
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Registration successful!',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        // Extract error message from response body
        final errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Unknown error';
        Get.snackbar('Error', 'Registration failed: $errorMessage',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // Login method with feedback
Future<bool> login(String email, String password) async {
    try {
      // Step 1: You give your email and password to the guard (server)
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      // Step 2: The guard checks your details with the control room (the server)
      if (response.statusCode == 200) {
        final data = jsonDecode(
            response.body); // The control room says "yes, you're verified!"

        // Step 3: The guard notes your user ID and role (like writing them down)
        userId.value = data['userId'] ?? '';
        userRole.value = data['role'] ?? 'user';
        user.value = data['user'] ?? {};

        // Step 4: The guard remembers you for next time (like writing it on paper)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['userId']);
        await prefs.setString('role', data['role']);
        await prefs.setString('user', jsonEncode(data['user']));

        // Step 5: The guard opens the door (navigates you to the products page)
        Get.offAllNamed('/products');
        return true; // Access granted
      } else {
        // Step 6: If the guard finds a problem, they show an error message (access denied)
        final errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Unknown error';

        // Additional error handling: Capture specific error details if available
        String detailedError = '';
        if (errorResponse.containsKey('error')) {
          detailedError = errorResponse['error'];
        } else if (errorMessage.contains('email')) {
          detailedError =
              'The email you entered is incorrect or not registered.';
        } else if (errorMessage.contains('password')) {
          detailedError = 'The password you entered is incorrect.';
        } else {
          detailedError = 'Something went wrong. Please try again later.';
        }

        print('Login Error: $detailedError'); // Guard talks about the issue

        // Show more detailed error message to the user
        Get.snackbar('Error', detailedError,
            snackPosition: SnackPosition.BOTTOM);
        return false; // Access denied
      }
    } catch (e) {
      // Step 7: If there's a problem (maybe the control room is unavailable), show an error
      print('Login Exception: $e');
      String errorMessage =
          'Connection failed: $e. Please check your internet connection or try again later.';
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return false; // Access denied
    }
  }

  // Auto login method
  Future<void> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      if (storedUserId != null) {
        userId.value = storedUserId;
        userRole.value = prefs.getString('role') ?? 'user';

        // Load user data if available
        final storedUser = prefs.getString('user');
        if (storedUser != null) {
          user.value = jsonDecode(storedUser);
        }

        Get.offAllNamed('/products');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar('Error', 'Auto login failed: $e');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      userId.value = '';
      userRole.value = 'user'; // Reset role during logout
      user.clear(); // Clear user data
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    }
  }
}
