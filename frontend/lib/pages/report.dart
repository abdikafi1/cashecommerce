 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart'; // Import the controller
import '../models/transaction.dart'; // Import the transaction model

class TransactionReportPage extends StatelessWidget {
  final ProductController productController =
      Get.find<ProductController>(); // Getting the ProductController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Report'),
      ),
      body: Obx(() {
        // If the transactions list is still loading, show a loading spinner
        if (productController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // If there are no transactions, show a "No transactions" message
        if (productController.transactions.isEmpty) {
          return Center(child: Text('No transactions available.'));
        }

        // Display the list of transactions
        return ListView.builder(
          itemCount: productController.transactions.length,
          itemBuilder: (context, index) {
            final transaction = productController.transactions[index];
            return Card(
              margin: EdgeInsets.all(10),
              elevation: 5,
              child: ListTile(
                contentPadding: EdgeInsets.all(15),
                title: Text('Transaction ID: ${transaction.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Total Amount: \$${transaction.totalAmount.toStringAsFixed(2)}'),
                    SizedBox(height: 5),
                    Text(
                        'Date: ${formatDate(transaction.date)}'), // Format the date
                    SizedBox(height: 5),
                    Text('Products:'),
                    // Temporarily comment out the product name line for now
                    ...transaction.products.map((product) {
                      // print(product); // Debugging line to inspect product
                      return Text(
                          // '${product.name?.isNotEmpty == true ? product.name : 'Unknown Product'} x${product.quantity}'
                          'Unknown Product x${product.quantity}'); // Fallback name
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Helper function to format date in a readable format
  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute}';
  }
}
