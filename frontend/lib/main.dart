import 'package:flutter/material.dart';
import 'package:frontend/pages/logn.dart';
import 'package:frontend/pages/product_lisr.dart';
import 'package:frontend/pages/report.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/auth_controller.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/pages/cart.dart';
import 'package:frontend/pages/checkout.dart';
import 'package:frontend/pages/transaction.dart';
import 'package:frontend/pages/report.dart';
import 'package:frontend/pages/register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize GetX controllers
    Get.put(AuthController());
    Get.put(ProductController());

    return GetMaterialApp(
      title: 'Flutter E-Commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/products', page: () => ProductListPage()),
        GetPage(name: '/cart', page: () => CartPage()),
        GetPage(name: '/checkout', page: () => CheckoutPage()),
        GetPage(name: '/transaction', page: () => TransactionPage()),
        GetPage(
            name: '/transactionReport', page: () => TransactionReportPage()),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:frontend/controllers/auth_controller.dart';
// import 'package:frontend/pages/logn.dart';
// import 'package:frontend/pages/product_lisr.dart';
// import 'package:frontend/pages/register.dart';
// import 'package:get/get.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final authController = Get.put(AuthController());
//   await authController
//       .autoLogin(); // Ensure autoLogin is completed before running the app

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       initialRoute: '/',
//       getPages: [
//         GetPage(name: '/login', page: () => LoginPage()),
//         GetPage(name: '/register', page: () => RegisterPage()),
//         GetPage(
//           name: '/products',
//           page: () {
//             final authController = Get.find<AuthController>();
//             return authController.token.isNotEmpty
//                 ? ProductListPage()
//                 : LoginPage(); // Redirect to LoginPage if no token
//           },
//         ),
//         // Add other pages...
//       ],
//       home: Obx(() {
//         final authController = Get.find<AuthController>();
//         // Wait for the autoLogin process to finish and display the correct page
//         if (authController.token.isEmpty) {
//           return LoginPage(); // Show LoginPage if token is empty
//         } else {
//           return ProductListPage(); // Show ProductListPage if token is not empty
//         }
//       }),
//     );
//   }
// }
