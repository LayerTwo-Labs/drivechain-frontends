import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';

class UTXO {
  final String txid;
  final int vout;
  final String address;
  final String account;
  final String redeemScript;
  final String scriptPubKey;
  final double amount;
  final int confirmations;
  final bool spendable;
  final bool solvable;
  final bool safe;
  final String raw;

  UTXO({
    required this.txid,
    required this.vout,
    required this.address,
    required this.account,
    required this.redeemScript,
    required this.scriptPubKey,
    required this.amount,
    required this.confirmations,
    required this.spendable,
    required this.solvable,
    required this.safe,
    required this.raw,
  });

  factory UTXO.fromMap(Map<String, dynamic> map) {
    return UTXO(
      txid: map['txid'] ?? '',
      vout: map['vout'] ?? 0,
      address: map['address'] ?? '',
      account: map['account'] ?? '',
      redeemScript: map['redeemScript'] ?? '',
      scriptPubKey: map['scriptPubKey'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      confirmations: map['confirmations'] ?? 0,
      spendable: map['spendable'] ?? false,
      solvable: map['solvable'] ?? false,
      safe: map['safe'] ?? false,
      raw: jsonEncode(map),
    );
  }

  static UTXO fromJson(String json) => UTXO.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'txid': txid,
        'vout': vout,
        'address': address,
        'account': account,
        'redeemScript': redeemScript,
        'scriptPubKey': scriptPubKey,
        'amount': amount,
        'confirmations': confirmations,
        'spendable': spendable,
        'solvable': solvable,
        'safe': safe,
        'raw': raw,
      };
}

class UTXOView extends StatefulWidget {
  final UTXO utxo;

  const UTXOView({super.key, required this.utxo});

  @override
  State<UTXOView> createState() => _UTXOViewState();
}

class _UTXOViewState extends State<UTXOView> {
  bool expanded = false;
  late Map<String, dynamic> decodedTx;
  @override
  void initState() {
    super.initState();
    decodedTx = jsonDecode(widget.utxo.raw);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueContainer(
              width: expanded ? 95 : 70,
              icon: widget.utxo.confirmations >= 1
                  ? Tooltip(
                      message: '${widget.utxo.confirmations} confirmations',
                      child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
                    )
                  : Tooltip(
                      message: 'Unconfirmed',
                      child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
                    ),
              copyable: false,
              value: extractTXTitle(widget.utxo),
              trailingText: 'Spendable: ${widget.utxo.spendable}',
            ),
          ),
          if (expanded)
            ExpandedTXView(
              decodedTX: decodedTx,
              width: 95,
            ),
        ],
      ),
    );
  }

  String extractTXTitle(UTXO tx) {
    String title = '${tx.amount.toStringAsFixed(8)} SBTC';

    if (tx.address.isEmpty) {
      return '$title in ${tx.txid}';
    }

    if (tx.amount.isNegative || tx.amount == 0) {
      return '$title to ${tx.address}';
    }

    return '+$title from ${tx.address}';
  }
}
