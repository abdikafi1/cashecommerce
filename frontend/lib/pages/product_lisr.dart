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

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          // Logout button for both admin and user
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authController.logout();
              Get.offAllNamed('/login');
            },
          ),
          // Admin-specific actions
          if (authController.user.value['role'] == 'admin')
            IconButton(
              icon: Icon(Icons.report),
              onPressed: () {
                // Navigate to the transaction report page
                Get.to(TransactionReportPage());
              },
            ),
        ],
      ),
      body: Obx(() {
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
              child: ListTile(
                contentPadding: EdgeInsets.all(15),
                title: Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: \$${product.price}'),
                    SizedBox(height: 5),
                    Text('Description: ${product.description}'),
                  ],
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    productController.addToCart(product);
                    Get.snackbar(
                      'Added to Cart',
                      '${product.name} added to cart',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 3),
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: Obx(() {
        final authController = Get.find<AuthController>();
        if (authController.user.value['role'] == 'admin') {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => _showProductInputDialog(context),
                child: Icon(Icons.add),
                tooltip: 'Add Product',
              ),
            ],
          );
        }
        return Container();
      }),
      // Cart button for users
      bottomNavigationBar: Obx(() {
        if (authController.user.value['role'] == 'user') {
          return BottomAppBar(
            child: ElevatedButton(
              onPressed: () {
                if (productController.cart.isNotEmpty) {
                  Get.to(CartPage());
                } else {
                  Get.snackbar(
                    'Cart Empty',
                    'Please add items to the cart to proceed.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text('View Cart'),
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
          title: Text('Enter Product Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
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
              child: Text('Save Data'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
