import 'dart:io';

import 'package:bitwindow/widgets/proof_of_funds_modal.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/api_mock.dart';

class _SignCall {
  _SignCall(this.walletId, this.message, this.address);

  final String walletId;
  final String message;
  final String address;
}

class _VerifyCall {
  _VerifyCall(this.address, this.signature, this.signerPublicKey);

  final String address;
  final String signature;
  final String signerPublicKey;
}

class _Wallet extends MockWalletAPI {
  final calls = <_SignCall>[];
  final verifyCalls = <_VerifyCall>[];

  @override
  Future<bool> verifyMessage(
    String walletId,
    String message,
    String signature,
    String address, {
    String signerPublicKey = '',
  }) async {
    verifyCalls.add(_VerifyCall(address, signature, signerPublicKey));
    return signerPublicKey == 'pub-$address';
  }

  @override
  Future<SignMessageResponse> signMessage(String walletId, String message, String address) async {
    calls.add(_SignCall(walletId, message, address));
    if (address == 'tb1qnotours') {
      throw WalletException('address is not in the wallet');
    }
    return SignMessageResponse(signature: 'sig-$address', publicKey: 'pub-$address');
  }
}

class _Bitwindow extends MockAPI {
  _Bitwindow() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _wallet = _Wallet();

  @override
  _Wallet get wallet => _wallet;
}

class _OrchestratorWallet implements OrchestratorWalletRPC {
  @override
  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) async => wmpb.ListUnspentResponse(
    utxos: [
      wmpb.UnspentOutput(txid: 'aa', vout: 0, address: 'tb1qours', amountSats: Int64(150000000)),
      wmpb.UnspentOutput(txid: 'bb', vout: 1, address: 'tb1qnotours', amountSats: Int64(2000)),
    ],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _OrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Bitwindow bitwindow;
  late Directory dir;

  setUp(() async {
    await GetIt.I.reset();
    dir = await Directory.systemTemp.createTemp('proof_of_funds_test');
    bitwindow = _Bitwindow();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<EnforcerRPC>(MockEnforcerRPC());
    GetIt.I.registerSingleton<BitcoindConnection>(MockBitcoindConnection());
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator());
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(dir)..activeWalletId = 'w1');
  });

  tearDown(() async {
    await GetIt.I.reset();
    await dir.delete(recursive: true);
  });

  test('signs each UTXO through bitwindowd with the active wallet', () async {
    final file = '${dir.path}/proof.csv';

    await ProofOfFundsViewModel().generateProofOfFunds(file, 'I own these coins', false);

    expect(bitwindow.wallet.calls.map((c) => c.address), ['tb1qours', 'tb1qnotours']);
    expect(bitwindow.wallet.calls.map((c) => c.walletId).toSet(), {'w1'});
    expect(bitwindow.wallet.calls.map((c) => c.message).toSet(), {'I own these coins'});

    final lines = (await File(file).readAsString()).trim().split('\n');
    expect(lines, [
      'blockchain,txid,address,message,signature,amount,publicKey',
      'BTC,aa,tb1qours,I own these coins,sig-tb1qours,1.5,pub-tb1qours',
      'BTC,bb,tb1qnotours,I own these coins,,0.00002,',
    ]);
  });

  test('checks each signed row in bitwindowd with the key from the row', () async {
    final file = File('${dir.path}/proof.csv');
    await file.writeAsString(
      [
        'blockchain,txid,address,message,signature,amount,publicKey',
        'BTC,aa,tb1pours,hi,sig-a,1.5,pub-tb1pours',
        'BTC,bb,tb1qours,hi,sig-b,0.5,pub-someone-else',
        'BTC,cc,tb1qempty,hi,,0.25,',
      ].join('\n'),
    );

    final result = await ProofOfFundsViewModel().verifyProofOfFunds(file.path);

    expect(bitwindow.wallet.verifyCalls.map((c) => (c.address, c.signature, c.signerPublicKey)), [
      ('tb1pours', 'sig-a', 'pub-tb1pours'),
      ('tb1qours', 'sig-b', 'pub-someone-else'),
    ]);
    expect(result.totalCount, 3);
    expect(result.validCount, 1);
    expect(result.totalBTC, 1.5);
  });
}
