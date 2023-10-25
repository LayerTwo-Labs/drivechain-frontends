import 'dart:async';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc.dart';

class Withdrawals extends StatefulWidget {
  const Withdrawals({super.key});

  @override
  WithdrawalsState createState() => WithdrawalsState();
}

class WithdrawalsState extends State<Withdrawals> {
  Timer? _timer;
  List<Withdrawal> _withdrawals = [];

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final fetched = await _fetchWithdrawals();
      setState(() {
        _withdrawals = fetched;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WithdrawalTableView(withdrawals: _withdrawals);
  }
}

Future<List<Withdrawal>> _fetchWithdrawals() async {
  final withdrawalIDs = await rpc.call("listmywithdrawals") as List<dynamic>;

  final nullableWithdrawalFutures = withdrawalIDs.map((w) async {
    final id = w["id"];
    try {
      final withdrawal = await rpc.call("getwithdrawal", [id]);
      return Withdrawal.fromJson(id, withdrawal);
    } on RPCException catch (err) {
      // This is expected. Not all withdrawal show up right away. Not exactly
      // sure why, TBH.
      if (err.errorCode == errWithdrawalNotFound) {
        log.t("withdrawal is not yet found: $id");
        return Withdrawal(
          id: id,
          destination: "",
          refundDestination: "",
          amount: 0,
          amountMainChainFee: 0,
          status: "Not yet found", // TODO: better status here
          hashBlindTx: "",
        );
      }

      log.e("could not fetch withdrawal: $err");

      rethrow;
    } catch (e) {
      rethrow;
    }
  });

  final nullable = await Future.wait(nullableWithdrawalFutures);
  return nullable.toList();
}

class Withdrawal {
  // NOT a TXID! Not completely sure what kind of ID it is, tbh...
  final String id;
  final String destination;
  final String refundDestination;
  // Satoshis
  final int amount;

  // Satoshis
  final int amountMainChainFee;

  final String status;
  final String hashBlindTx;

  Withdrawal({
    required this.id,
    required this.destination,
    required this.refundDestination,
    required this.amount,
    required this.amountMainChainFee,
    required this.status,
    required this.hashBlindTx,
  });

  factory Withdrawal.fromJson(String id, Map<String, dynamic> json) {
    return Withdrawal(
      id: id,
      destination: json['destination'],
      refundDestination: json['refunddestination'],
      amount: json['amount'],
      amountMainChainFee: json['amountmainchainfee'],
      status: json['status'],
      hashBlindTx: json['hashblindtx'],
    );
  }
}

class WithdrawalTableView extends StatelessWidget {
  final List<Withdrawal> withdrawals;

  const WithdrawalTableView({
    super.key,
    required this.withdrawals,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Destination')),
            DataColumn(label: Text('Refund Destination')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Main Chain Fee')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Hash Blind Tx')),
          ],
          rows: withdrawals.map((transaction) {
            return DataRow(
              cells: [
                DataCell(SelectableText(transaction.id)),
                DataCell(SelectableText(transaction.destination)),
                DataCell(SelectableText(transaction.refundDestination)),
                DataCell(SelectableText(transaction.amount.toString())),
                DataCell(
                    SelectableText(transaction.amountMainChainFee.toString())),
                DataCell(SelectableText(transaction.status)),
                DataCell(SelectableText(transaction.hashBlindTx)),
              ],
            );
          }).toList(),
        ));
  }
}
