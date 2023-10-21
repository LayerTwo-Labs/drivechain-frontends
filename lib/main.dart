import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sidesail/console.dart';
import 'package:sidesail/deposit_address.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc.dart';

void main() {
  runApp(const MyApp());
}

const appName = 'SideSail';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _depositAddress = "none";
  void _onWithdraw() async {
    // 1. Get refund address. This can be any address we control on the SC.
    final refund = await rpc
        .call("getnewaddress", ["Sidechain withdrawal refund"]) as String;

    log.d("got refund address: $refund");

    // 2. Get SC fee estimate
    final estimate =
        await rpc.call("estimatesmartfee", [6]) as Map<String, dynamic>;

    if (estimate.containsKey("errors")) {
      log.w("could not estimate fee: ${estimate["errors"]}");
    }

    final btcPerKb = estimate.containsKey("feerate")
        ? estimate["feerate"] as double
        : 0.0001; // 10 sats/byte

    // Who knows!
    const kbyteInWithdrawal = 5;

    final sidechainFee = btcPerKb * kbyteInWithdrawal;

    log.d("withdrawal: adding SC fee of $sidechainFee");

    // 3. Get MC fee
    // This happens with the `getaveragemainchainfees` RPC. This
    // is passed straight on to the mainchain `getaveragefee`,
    // which is added in the Drivechain implementation of Bitcoin
    // Core.
    // This, as opposed to `estimatesmartfee`, is used is because
    // we need everyone to get the same results for withdrawal
    // bundle validation.
    //
    // The above might not actually be correct... What's the best
    // way of doing this?

    const mainchainFee = 0.001;

    final withdrawalAddress = _withdrawalAddress.text;
    final withdrawalAmount = double.parse(_withdrawalAmount.text);

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Confirm withdrawal"),
              content: Text(
                "Confirm withdrawal: $withdrawalAmount BTC to $withdrawalAddress for $sidechainFee SC fee and $mainchainFee MC fee",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    log.i(
                        "doing withdrawal: $withdrawalAmount BTC to $withdrawalAddress for $sidechainFee SC fee and $mainchainFee MC fee");

                    final withdrawalTxid = await rpc.call("createwithdrawal", [
                      withdrawalAddress,
                      refund,
                      withdrawalAmount,
                      sidechainFee,
                      mainchainFee,
                    ]);

                    log.i("txid: $withdrawalTxid");

                    // ignore: use_build_context_synchronously
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Success"),
                              content: Text(
                                "Submitted withdrawal successfully! TXID: $withdrawalTxid",
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("OK"))
                              ],
                            ));
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  final TextEditingController _withdrawalAddress = TextEditingController();

  final TextEditingController _withdrawalAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      body: Center(
        child: SizedBox(
            width: 800,
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: RpcWidget()),
                  ],
                ),
                Row(
                  children: [
                    // TODO: this needs to be a P2PKH address. Validate this,
                    // somehow.
                    // can probably use https://github.com/dart-bitcoin/bitcoin_flutter
                    // addressToOutputScript
                    const Text("Mainchain address: "),
                    Expanded(
                      child: TextField(
                        controller: _withdrawalAddress,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Amount: "),
                    Expanded(
                      child: TextField(
                        controller: _withdrawalAmount,
                        inputFormatters: [
                          // digits plus dot
                          FilteringTextInputFormatter.allow(RegExp(r'[.0-9]'))
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _onWithdraw,
                      child: const Text("Submit withdrawal"),
                    )
                  ],
                ),
                Row(
                  children: const [Text("Deposit stuff")],
                ),
                Row(
                  children: [
                    DepositAddress(_depositAddress),
                    ElevatedButton(
                      onPressed: () async {
                        var address = await generateDepositAddress();
                        setState(() {
                          _depositAddress = address;
                        });
                      },
                      child: const Text("Generate"),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
