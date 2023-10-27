import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DepositAddress extends StatelessWidget {
  const DepositAddress(this.address, {super.key});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Deposit to this address from the mainchain: ',
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied address'),
                    ),
                  );
                },
                child: Text(
                  address,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
