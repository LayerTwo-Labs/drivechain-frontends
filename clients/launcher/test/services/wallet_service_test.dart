import 'package:flutter_test/flutter_test.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '.';
      }
      return null;
    },
  );
  
  group('WalletService', () {
    late WalletService walletService;

    setUp(() {
      walletService = WalletService();
    });

    group('BIP39 Test Vectors', () {

      test('Test Vector 2 - 12 words', () async {
        const mnemonic = 'legal winner thank year wave sausage worth useful legal winner thank yellow';
        const passphrase = 'TREZOR';
        
        final walletData = await walletService.createWalletData(mnemonic, passphrase: passphrase,);
        
        expect(walletData.seedHex, equals('2e8905819b8723fe2c1d161860e5ee1830318dbf49a83bd451cfb8440c28bd6fa457fe1296106559a3c80937a1c1069be3a3a5bd381ee6260e8d9739fce1f607'),);
      });

      test('Test Vector 3 - 18 words', () async {
        const mnemonic = 'letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter always';
        const passphrase = 'TREZOR';
        
        final walletData = await walletService.createWalletData(mnemonic, passphrase: passphrase,);
        
        expect(walletData.seedHex, equals('107d7c02a5aa6f38c58083ff74f04c607c2d2c0ecc55501dadd72d025b751bc27fe913ffb796f841c49b1d33b610cf0e91d3aa239027f5e99fe4ce9e5088cd65'),);
      });

      test('Test Vector 4 - 24 words', () async {
        const mnemonic = 'letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic bless';
        const passphrase = 'TREZOR';
        
        final walletData = await walletService.createWalletData(mnemonic, passphrase: passphrase,);
        
        expect(walletData.seedHex, equals('c0c519bd0e91a2ed54357d9d1ebef6f5af218a153624cf4f2da911a0ed8f7a09e2ef61af0aca007096df430022f7a2b6fb91661a9589097069720d015e4e982f'),);
      });

      test('Test Vector 5 - Real world example', () async {
        const mnemonic = 'jelly better achieve collect unaware mountain thought cargo oxygen act hood bridge';
        const passphrase = 'TREZOR';
        
        final walletData = await walletService.createWalletData(mnemonic, passphrase: passphrase,);
        
        expect(walletData.seedHex, equals('b5b6d0127db1a9d2226af0c3346031d77af31e918dba64287a1b44b8ebf63cdd52676f672a290aae502472cf2d602c051f3e6f18055e84e4c43897fc4e51a6ff'),);
      });
    });

    group('BIP32 Derivation Tests', () {
      test('Test Vector 1 - Basic HD Key Generation', () async {
        const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        const passphrase = 'TREZOR';
        
        final walletData = await walletService.createWalletData(mnemonic, passphrase: passphrase);
        
        expect(walletData.masterKey, isNotEmpty);
        expect(walletData.chainCode, isNotEmpty);
        expect(walletData.hdKeyData, isNotEmpty);
        expect(walletData.bip32Path, equals("m/44'/0'/0'"));
      });

      test('Test Vector 2 - Complex Mnemonic HD Key Generation', () async {
        const mnemonic = 'dignity pass list indicate nasty swamp pool script soccer toe leaf photo multiply desk host tomato cradle drill spread actor shine dismiss champion exotic';
        const passphrase = 'TREZOR';
        
        final walletData = await walletService.createWalletData(mnemonic, passphrase: passphrase);
        
        expect(walletData.seedHex, equals('ff7f3184df8696d8bef94b6c03114dbee0ef89ff938712301d27ed8336ca89ef9635da20af07d4175f2bf5f3de130f39c9d9e8dd0472489c19b1a020a940da67'));
      });
    });

    group('Wallet Creation and Storage', () {
      test('creates wallet from mnemonic and stores it', () async {
        const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
        
        final result = await walletService.createFromMnemonic(mnemonic);
        expect(result, isTrue);
        
        final hasWallet = await walletService.hasWallet();
        expect(hasWallet, isTrue);
        
        final storedWallet = await walletService.getWalletData();
        expect(storedWallet, isNotNull);
        expect(storedWallet!.mnemonic, equals(mnemonic));
      });

      test('creates wallet from hex and stores it', () async {
        const hexKey = '77c2b00716cec7213839159e404db50d';
        
        final result = await walletService.createFromHex(hexKey);
        expect(result, isTrue);
        
        final hasWallet = await walletService.hasWallet();
        expect(hasWallet, isTrue);
        
        final storedWallet = await walletService.getWalletData();
        expect(storedWallet, isNotNull);
        expect(storedWallet!.mnemonic, equals('jelly better achieve collect unaware mountain thought cargo oxygen act hood bridge'));
      });
    });
  });
} 