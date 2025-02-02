import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/auth_controller.dart'; // Import AuthController
import '../models/product.dart';
import '../pages/cart.dart'; // Import Cart Page
import '../pages/report.dart'; // Import Transaction Report Page

class ProductListPage extends StatelessWidget {
  final ProductController productController =
      Get.put(ProductController()); // GetX Controller

  // Define the primary color
  final Color primaryColor = Color(0xFF125C33);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        backgroundColor: primaryColor,
        actions: [
          // Logout button for both admin and user
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authController.logout();
              Get.offAllNamed('/login');
            },
          ),
          // Admin-specific actions
          if (authController.user.value['role'] == 'admin')
            IconButton(
              icon: Icon(Icons.report, color: Colors.white),
              onPressed: () {
                // Navigate to the transaction report page
                Get.to(TransactionReportPage());
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (productController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: productController.products.length,
            itemBuilder: (context, index) {
              final product = productController.products[index];
              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'Price: \$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Description: ${product.description}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_shopping_cart, color: primaryColor),
                    onPressed: () {
                      productController.addToCart(product);
                      Get.snackbar(
                        'Added to Cart',
                        '${product.name} added to cart',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: Duration(seconds: 3),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: Obx(() {
        if (authController.user.value['role'] == 'admin') {
          return FloatingActionButton(
            onPressed: () => _showProductInputDialog(context),
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: primaryColor,
            tooltip: 'Add Product',
          );
        }
        return Container();
      }),
      // Cart button for users
      bottomNavigationBar: Obx(() {
        if (authController.user.value['role'] == 'user') {
          return BottomAppBar(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  if (productController.cart.isNotEmpty) {
                    Get.to(CartPage());
                  } else {
                    Get.snackbar(
                      'Cart Empty',
                      'Please add items to the cart to proceed.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'View Cart',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          );
        }
        return Container();
      }),
    );
  }

  // Function to show the dialog for product data entry
  void _showProductInputDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Product Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate fields before saving
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    imageUrlController.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please fill in all fields.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                } else {
                  final newProduct = Product(
                    id: DateTime.now()
                        .toString(), // Generate a unique id or use the backend response
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    description: descriptionController.text,
                    imageUrl: imageUrlController.text,
                  );
                  productController.addProduct(newProduct); // Add new product
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
