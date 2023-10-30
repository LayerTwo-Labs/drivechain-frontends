import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

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
              SailText.primary14(
                'Deposit to this address from the mainchain: ',
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: SailText.primary14('Copied address'),
                    ),
                  );
                },
                child: SailText.primary14(address),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
