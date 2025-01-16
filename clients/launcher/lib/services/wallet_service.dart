import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:path_provider/path_provider.dart';
import 'package:launcher/env.dart';

class WalletData {

  final String bip32Path;
  final String mnemonic;
  final String seedHex;
  final String hdKeyData;
  final String masterKey;
  final String chainCode;
  final String bip39Bin;
  final String bip39Csum;
  final String bip39CsumHex;

  WalletData({
    required this.bip32Path,
    required this.mnemonic,
    required this.seedHex,
    required this.hdKeyData,
    required this.masterKey,
    required this.chainCode,
    required this.bip39Bin,
    required this.bip39Csum,
    required this.bip39CsumHex,
  });

  Map<String, dynamic> toJson() => {
    'bip32_path': bip32Path,
    'mnemonic': mnemonic,
    'seed_hex': seedHex,
    'hd_key_data': hdKeyData,
    'master_key': masterKey,
    'chain_code': chainCode,
    'bip39_bin': bip39Bin,
    'bip39_csum': bip39Csum,
    'bip39_csum_hex': bip39CsumHex,
  };

  static WalletData fromJson(Map<String, dynamic> json) => WalletData(
    bip32Path: json['bip32_path'],
    mnemonic: json['mnemonic'],
    seedHex: json['seed_hex'],
    hdKeyData: json['hd_key_data'],
    masterKey: json['master_key'],
    chainCode: json['chain_code'],
    bip39Bin: json['bip39_bin'],
    bip39Csum: json['bip39_csum'],
    bip39CsumHex: json['bip39_csum_hex'],
  );
}

class WalletService {
  Future<String> get _walletDir async {
    try {
      final appDir = await Environment.datadir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      if (!await walletDir.exists()) {
        await walletDir.create(recursive: true);
      }
      return walletDir.path;
    } catch (e) {
      rethrow;
    }
  }

  Future<File> get _walletFile async {
    final dir = await _walletDir;
    return File('$dir/master_starter.json');
  }

  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  String _hexToBinary(String hex) {
    return BigInt.parse(hex, radix: 16).toRadixString(2).padLeft(hex.length * 4, '0');
  }

  (String, String) _getChecksumFromEntropy(String entropyHex) {
    final entropyBytes = hex.decode(entropyHex);
    final entropyBits = entropyBytes.length * 8;
    final checksumLength = entropyBits ~/ 32;

    final hash = sha256.convert(entropyBytes);
    final checksumByte = hash.bytes[0];
    
    var checksumBinary = '';
    for (var i = 0; i < checksumLength; i++) {
      checksumBinary += ((checksumByte >> (7 - i)) & 1).toString();
    }
    
    final checksumInt = int.parse(checksumBinary, radix: 2);
    final checksumHex = checksumInt.toRadixString(16).padLeft(2, '0');
    
    return (checksumBinary, checksumHex);
  }

  Uint8List _generateSeed(String mnemonic, {String? passphrase}) {
    final normalizedMnemonic = mnemonic.replaceAll(RegExp(r'\s+'), ' ').trim();
    final normalizedPassphrase = passphrase?.trim() ?? '';
    
    final password = utf8.encode(normalizedMnemonic);
    final salt = utf8.encode('mnemonic$normalizedPassphrase');
    
    final params = Pbkdf2Parameters(Uint8List.fromList(salt), 2048, 64);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128));
    pbkdf2.init(params);
    
    return pbkdf2.process(Uint8List.fromList(password));
  }

  Future<WalletData> createWalletData(String mnemonic, {String? passphrase}) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }

    final seed = _generateSeed(mnemonic, passphrase: passphrase);
    final seedHex = hex.encode(seed);
    final root = bip32.BIP32.fromSeed(seed);
    
    final entropyHex = bip39.mnemonicToEntropy(mnemonic);
    final entropyBinary = _hexToBinary(entropyHex);
    final (checksumBinary, checksumHex) = _getChecksumFromEntropy(entropyHex);
    final bip39Bin = entropyBinary + checksumBinary;

    return WalletData(
      bip32Path: "m/44'/0'/0'",
      mnemonic: mnemonic,
      seedHex: seedHex,
      hdKeyData: hex.encode(Uint8List.fromList([...root.privateKey!, ...root.chainCode])),
      masterKey: hex.encode(root.privateKey!),
      chainCode: hex.encode(root.chainCode),
      bip39Bin: bip39Bin,
      bip39Csum: checksumBinary,
      bip39CsumHex: checksumHex,
    );
  }

  Future<bool> createFromMnemonic(String mnemonic, {String? passphrase}) async {
    try {
      final walletData = await createWalletData(mnemonic, passphrase: passphrase);
      final file = await _walletFile;
      await file.writeAsString(jsonEncode(walletData.toJson()));
      print('Successfully wrote wallet data');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createFromHex(String hexKey) async {
    try {
      final entropy = hex.decode(hexKey);
      final mnemonic = bip39.entropyToMnemonic(hex.encode(entropy));
      return await createFromMnemonic(mnemonic);
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasWallet() async {
    final file = await _walletFile;
    return file.exists();
  }

  Future<WalletData?> getWalletData() async {
    try {
      final file = await _walletFile;
      if (!await file.exists()) return null;
      final jsonStr = await file.readAsString();
      return WalletData.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return null;
    }
  }
} 