import 'dart:io';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

class _FakeWalletRPC extends OrchestratorWalletRPC {
  _FakeWalletRPC()
    : super.fromTransports(
        unary: connect.Transport(
          baseUrl: 'http://127.0.0.1:1',
          codec: const ProtoCodec(),
          httpClient: createHttpClient(),
        ),
        stream: connect.Transport(
          baseUrl: 'http://127.0.0.1:1',
          codec: const ProtoCodec(),
          httpClient: createHttpClient(),
        ),
      );

  int generateWalletCalls = 0;
  String? generatedName;
  String? generatedMnemonic;
  String? generatedPassphrase;

  @override
  Future<wmpb.GenerateWalletResponse> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) async {
    generateWalletCalls++;
    generatedName = name;
    generatedMnemonic = customMnemonic;
    generatedPassphrase = passphrase;
    return wmpb.GenerateWalletResponse(walletId: 'wallet-1', mnemonic: customMnemonic);
  }
}

class _FakeOrchestratorRPC extends OrchestratorRPC {
  _FakeOrchestratorRPC(this._fake) : super(host: '127.0.0.1', port: 1);

  final _FakeWalletRPC _fake;

  @override
  // ignore: overridden_fields
  late final OrchestratorWalletRPC wallet = _fake;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    GetIt.I.registerSingleton<WalletReaderProvider>(
      WalletReaderProvider(Directory.systemTemp),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('generateWalletFromEntropy preview does not create a backend wallet', () async {
    final fake = _FakeWalletRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));
    final provider = WalletWriterProvider(bitwindowAppDir: Directory.systemTemp);

    final wallet = await provider.generateWalletFromEntropy(
      List<int>.filled(16, 0),
      doNotSave: true,
    );

    expect(fake.generateWalletCalls, 0);
    expect(
      wallet['mnemonic'],
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    expect(wallet['bip39_binary'], List.filled(128, '0').join());
    expect(wallet['bip39_checksum'], '0011');
  });

  test('generateWalletFromEntropy final create saves once with provided name', () async {
    final fake = _FakeWalletRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));
    final provider = WalletWriterProvider(bitwindowAppDir: Directory.systemTemp);

    final wallet = await provider.generateWalletFromEntropy(
      List<int>.filled(16, 0),
      name: 'Paranoid Wallet',
    );

    expect(fake.generateWalletCalls, 1);
    expect(fake.generatedName, 'Paranoid Wallet');
    expect(
      fake.generatedMnemonic,
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    );
    expect(wallet['wallet_id'], 'wallet-1');
  });
}
