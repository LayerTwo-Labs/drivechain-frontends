import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:bitwindow/servers/mainchain_rpc.dart';

class ProofOfFundsViewModel extends BaseViewModel {
  final mainchain = GetIt.I.get<MainchainRPC>();
  
  final fileOutController = TextEditingController();
  final fileInController = TextEditingController();
  final messageController = TextEditingController();
  bool skipFirstRow = false;
  String? result;

  void toggleSkipFirstRow() {
    skipFirstRow = !skipFirstRow;
    notifyListeners();
  }

  Future<void> generateProof() async {
    try {
      final filePath = fileOutController.text;
      if (filePath.isEmpty) {
        result = 'Please enter an output file path';
        notifyListeners();
        return;
      }

      // Phase 1: List unspent outputs
      final unspentOutputs = await mainchain.listUnspent();
      final file = File(filePath);
      var output = 'blockchain,txid,address,scriptPubKey,amount\n';
      
      for (var utxo in unspentOutputs) {
        output += 'BTC,${utxo.txid},${utxo.address},${utxo.scriptPubKey},${utxo.amount}\n';
      }
      
      await file.writeAsString(output);

      // Phase 2: Add message
      final message = messageController.text.isNotEmpty ? messageController.text : _generateRandomHex();
      final lines = await file.readAsLines();
      output = '${lines[0]},message\n';
      
      for (var i = 1; i < lines.length; i++) {
        output += '${lines[i]},$message\n';
      }
      
      await file.writeAsString(output);

      // Phase 3: Sign messages
      final signedLines = await file.readAsLines();
      output = '${signedLines[0]},signature\n';
      
      for (var i = 1; i < signedLines.length; i++) {
        final parts = signedLines[i].split(',');
        final signature = await mainchain.signMessage(parts[2], parts[4]);
        output += '${signedLines[i]},$signature\n';
      }
      
      await file.writeAsString(output);

      result = 'Proof of funds generated successfully';
      notifyListeners();
    } catch (e) {
      result = 'Error generating proof: $e';
      notifyListeners();
    }
  }

  Future<void> verifyProof() async {
    try {
      final filePath = fileInController.text;
      if (filePath.isEmpty) {
        result = 'Please enter an input file path';
        notifyListeners();
        return;
      }

      final file = File(filePath);
      final lines = await file.readAsLines();
      
      if (lines.length < 2) {
        result = 'Invalid file format';
        notifyListeners();
        return;
      }

      var validCount = 0;
      var totalBTC = 0.0;
      var output = skipFirstRow ? '' : 'blockchain,txid,address,scriptPubKey,message,signature,amount,valid\n';

      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].split(',');
        if (parts.length < 6) continue;

        final isValid = await mainchain.verifyMessage(parts[2], parts[5], parts[4]);
        if (isValid) {
          validCount++;
          totalBTC += double.parse(parts[6]);
        }

        output += '${lines[i]},${isValid ? "true" : "false"}\n';
      }

      if (!skipFirstRow) {
        output = 'summary: $validCount signatures of ${lines.length - 1} valid. total BTC: $totalBTC\n$output';
      }

      await file.writeAsString(output);

      result = 'Verification complete. Valid signatures: $validCount/${lines.length - 1}, Total BTC: $totalBTC';
      notifyListeners();
    } catch (e) {
      result = 'Error verifying proof: $e';
      notifyListeners();
    }
  }

  String _generateRandomHex() {
    final random = List.generate(16, (_) => '0123456789ABCDEF'[DateTime.now().microsecondsSinceEpoch % 16]);
    return random.join();
  }
} 