import 'package:flutter/material.dart';
import 'package:frontend/pages/transaction.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class AdminTasks extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();
  final Color primaryColor = const Color(0xFF125C33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.report, color: Colors.white),
            onPressed: () {
              // Navigate to the report page or perform other admin actions
              Get.to(() => TransactionPage()); // Assuming ReportPage is defined
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                _buildSummaryCard('Total Products',
                    productController.products.length.toString()),
                const SizedBox(width: 16),
                _buildSummaryCard(
                    'Total Sales', '\$0.00'), // Replace with actual sales data
              ],
            ),
            const SizedBox(height: 24),

            // Product List
            Text(
              'All Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productController.products.length,
              itemBuilder: (context, index) {
                final product = productController.products[index];
                return _buildAdminProductCard(product);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductInputDialog(),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryColor,
        tooltip: 'Add Product',
      ),
    );
  }

  // Summary Card Widget
  Widget _buildSummaryCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Admin Product Card Widget
  Widget _buildAdminProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            product.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.grey.shade400,
              );
            },
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Price: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${product.description}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () => _showEditProductDialog(product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => productController.deleteProduct(product.id),
            ),
          ],
        ),
      ),
    );
  }

  // Edit Product Dialog
  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());
    final descriptionController =
        TextEditingController(text: product.description);
    final imageUrlController = TextEditingController(text: product.imageUrl);

    Get.dialog(
      AlertDialog(
        title: Text(
          'Edit Product',
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
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
                  duration: const Duration(seconds: 3),
                );
              } else {
                final updatedProduct = Product(
                  id: product.id,
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                );
                productController.updateProduct(updatedProduct);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show the dialog for product data entry
  void _showProductInputDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();

    Get.dialog(
      AlertDialog(
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
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
                  duration: const Duration(seconds: 3),
                );
              } else {
                final newProduct = Product(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                );
                productController.addProduct(newProduct);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
