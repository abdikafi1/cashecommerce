import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth_controller.dart';
import 'package:frontend/pages/register.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Attempt to log in
                bool success = await authController.login(
                  emailController.text,
                  passwordController.text,
                );
                if (success) {
                  // Navigate to the products page on successful login
                  Get.offAllNamed('/products');
                  Get.snackbar('Success', 'You have logged in successfully!',
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  // Show error message if login fails
                  Get.snackbar('Error', 'Login failed. Invalid credentials.',
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => Get.to(RegisterPage()),
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
