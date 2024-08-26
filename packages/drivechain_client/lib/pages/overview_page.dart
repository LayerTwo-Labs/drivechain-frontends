import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/service.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Drivechain RPC test'),
        ),
        body: FutureBuilder<List<Transaction>>(
          future: DrivechainService.of(context).listTransactions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final transaction = snapshot.data![index];
                  return ListTile(
                    title: Text(transaction.txid),
                    subtitle: Text("${transaction.sentSatoshi} sats"),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
