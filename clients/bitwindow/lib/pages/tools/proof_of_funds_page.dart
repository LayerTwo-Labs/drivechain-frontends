import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProofOfFundsPage extends StatelessWidget {
  const ProofOfFundsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proof of Funds'),
      ),
      body: const Center(
        child: Text(
          'Coming soon...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}