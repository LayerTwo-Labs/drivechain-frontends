import 'package:flutter/material.dart';
import 'package:sidechain_flutter_test/rpc.dart';

Future<String> generateDepositAddress() async {
  var address =
      await rpc.call("getnewaddress", ["Sidechain Deposit", "legacy"]);

  // This is actually just rather simple stuff. Should be able to
  // do this client side! Just needs the sidechain number, and we're
  // off to the races.
  var formatted = await rpc.call("formatdepositaddress", [address as String]);

  return formatted as String;
}

class DepositAddress extends StatelessWidget {
  const DepositAddress(this.address);

  final String address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        Row(
          children: [
            Text(
              'Deposit to this address from the mainchain: $address',
            ),
          ],
        ),
      ]),
    );
  }
}
