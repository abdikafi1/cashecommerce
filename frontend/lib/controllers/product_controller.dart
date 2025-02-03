import 'package:frontend/controllers/auth_controller.dart';
import 'package:frontend/pages/transaction.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/transaction.dart'; // Assuming you have a Transaction model
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs; // Observable list of products
  var isLoading = true.obs; // Observable loading state
  var cart = <ProductItem>[].obs; // Observable cart items
  var userId = ""
      .obs; // Observable user ID (dynamically fetched based on the logged-in user)
  var transactions = <Transaction>[].obs; // Observable list for transactions

  @override
  void onInit() {
    fetchProducts(); // Fetch products when the controller is initialized
    super.onInit();
  }

  // Dynamically set the user ID, you can call this method after the user logs in
  void setUserId(String id) {
    userId.value = id;
  }

  // Fetch products from the backend API
  Future<void> fetchProducts() async {
    isLoading(true); // Set loading to true before making the API call
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/products'));

      if (response.statusCode == 200) {
        final List<dynamic> productJson = json.decode(response.body);
        products.value =
            productJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("Error fetching products: $e");
      Get.snackbar('Error', 'Failed to load products',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false); // Stop the loading spinner after fetching
    }
  }

  // Add product to the list
  void addProduct(Product product) {
    products.add(product); // Add the new product to the products list
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/products/${product.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}'
        },
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedProduct = Product.fromJson(json.decode(response.body));
        final index = products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          products[index] = updatedProduct;
          products.refresh();
        }
      } else {
        // Attempt to extract the error message from the response body if available
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['message'] ?? 'Unknown error'
            : 'Failed to update product';
        throw Exception('Failed to update product: $errorMessage');
      }
    } catch (e) {
      // Display the error message in the snackbar
      Get.snackbar(
        'Error',
        'Failed to update product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
         
      );
    }
  }

  // // Update product
  // Future<void> updateProduct(Product product) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('http://localhost:5000/api/products/${product.id}'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${await _getToken()}'
  //       },
  //       body: jsonEncode(product.toJson()),
  //     );

  //     if (response.statusCode == 200) {
  //       final updatedProduct = Product.fromJson(json.decode(response.body));
  //       final index = products.indexWhere((p) => p.id == updatedProduct.id);
  //       if (index != -1) {
  //         products[index] = updatedProduct;
  //         products.refresh();
  //       }
  //     } else {
  //       throw Exception('Failed to update product');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
  //   }
  // }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/products/$productId'),
        headers: {'Authorization': 'Bearer ${await _getToken()}'},
      );

      if (response.statusCode == 200) {
        products.removeWhere((product) => product.id == productId);
        products.refresh();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
    }
  }

  // Add product to cart
  void addToCart(Product product) {
    int index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cart[index].quantity++; // If product already in cart, increment quantity
    } else {
      cart.add(ProductItem(
          product: product, quantity: 1)); // Add new product with quantity 1
    }
    cart.refresh(); // Refresh the cart list to reflect changes
  }

  // Remove product from cart
  void removeFromCart(Product product) {
    cart.removeWhere((item) => item.product.id == product.id);
    cart.refresh(); // Refresh the cart list to reflect changes
  }

  // Clear all items from the cart
  void clearCart() {
    cart.clear(); // Clear the cart
  }

  // Calculate total amount in the cart
  double get totalAmount {
    return cart.fold(
        0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Create transaction and send data to the backend
  Future<void> createTransaction() async {
    try {
      final authController = Get.find<AuthController>();
      if (authController.user.value == null) {
        throw Exception('User not authenticated');
      }

      final transactionProducts = cart.map((item) {
        return {
          'productId': item.product.id,
          'quantity': item.quantity,
        };
      }).toList();

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}'
        },
        body: jsonEncode({
          'userId': userId.value,
          'products': transactionProducts,
          'totalAmount': totalAmount,
        }),
      );

      if (response.statusCode == 201) {
        clearCart();
        Get.to(TransactionPage());
      } else {
        throw Exception('Failed to create transaction');
      }
    } catch (e) {
      Get.snackbar('Error', 'Transaction failed: ${e.toString()}');
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Fetch transactions for a user from the backend API
  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/transactions'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> transactionsJson = json.decode(response.body);
        transactions.value =
            transactionsJson.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      Get.snackbar('Error', 'Failed to fetch transactions',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// ProductItem class to store product and quantity in cart
class ProductItem {
  final Product product;
  int quantity;

  ProductItem({required this.product, this.quantity = 1});
}
