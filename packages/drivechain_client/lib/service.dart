import 'dart:math';

import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/timestamp.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:grpc/grpc.dart';

import 'gen/google/protobuf/empty.pb.dart';

class DrivechainService extends InheritedWidget {
  late final ClientChannel _channel;
  late final DrivechainServiceClient _client;

  DrivechainService({required super.child, super.key}) {
    _client = DrivechainServiceClient(DrivechainChannel());
  }

  Future<List<Transaction>> listTransactions() async {
    /*final response = await _client.listTransactions(Empty());
    return response.transactions;*/

    // Mock transactions for now
    return _generateMockTransactions(200);
  }

  List<Transaction> _generateMockTransactions(int n) {
    return List.generate(n, (index) {
      return Transaction(
        txid: index.toString(),
        feeSatoshi: Int64(Random().nextInt(1000)),
        receivedSatoshi: Int64(Random().nextInt(100000)),
        sentSatoshi: Int64(Random().nextInt(100000)),
        confirmationTime: Confirmation(
          height: index,
          timestamp: Timestamp(seconds: Int64(Random().nextInt(1000000000)), nanos: 0),
        ),
      );
    });
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DrivechainService of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DrivechainService>()!;
  }
}

class DrivechainChannel extends ClientChannel {
  DrivechainChannel()
      : super('localhost',
            port: 8080,
            options: const ChannelOptions(
              credentials: ChannelCredentials.insecure(),
            ));
}
