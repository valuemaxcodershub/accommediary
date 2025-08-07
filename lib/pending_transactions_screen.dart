import 'package:flutter/material.dart';

class PendingTransactionsScreen extends StatelessWidget {
  const PendingTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Transactions')),
      body: const Center(child: Text('Pending Transactions Screen')),
    );
  }
}
