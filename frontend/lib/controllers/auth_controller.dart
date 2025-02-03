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
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId.value = data['userId'] ?? '';
        userRole.value = data['role'] ?? 'user'; // Ensure role is set correctly
        user.value = data['user'] ?? {};

        // Debug log
        print('Login Successful - Role: ${userRole.value}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['userId']);
        await prefs.setString('role', data['role']);
        await prefs.setString('user', jsonEncode(data['user']));

        Get.offAllNamed('/products');
        return true;
      } else {
        final errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Unknown error';
        Get.snackbar('Error', 'Login failed: $errorMessage',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      print('Login Exception: $e');
      Get.snackbar('Error', 'Connection failed: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

Future<void> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      if (storedUserId != null) {
        userId.value = storedUserId;
        userRole.value =
            prefs.getString('role') ?? 'user'; // Ensure this is correct
        final storedUser = prefs.getString('user');
        if (storedUser != null) {
          user.value = jsonDecode(storedUser);
        }

        // Debug log
        print('AutoLogin Successful - Role: ${userRole.value}');
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
