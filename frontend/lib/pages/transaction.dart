import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction Complete')),
      body: Center(
        child: Text('Transaction completed!'),
      ),
    );
  }
}
