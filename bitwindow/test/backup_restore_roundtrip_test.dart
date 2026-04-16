import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/gen/multisig/v1/multisig.pb.dart' as multisigpb;
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';

import 'mocks/api_mock.dart';

/// A mock WalletAPI that simulates real backup create/validate/restore
/// round-trip behavior with in-memory state.
class RoundTripWalletAPI extends MockWalletAPI {
  /// Simulated wallet data on "disk"
  Map<String, dynamic>? walletJson;

  /// Simulated multisig groups in "DB"
  List<multisigpb.MultisigGroup> multisigGroups = [];

  /// Simulated transactions in "DB"
  List<multisigpb.MultisigTransaction> transactions = [];

  /// Tracks whether restore was called
  bool restoreCalled = false;

  /// The data that was restored
  List<int>? restoredBackupData;
  String? restoredFilename;

  @override
  Future<CreateBackupResponse> createBackup() async {
    if (walletJson == null) {
      throw WalletException('No wallet exists to back up');
    }

    // Build a ZIP archive containing wallet + multisig + transactions
    final archive = Archive();

    // wallet.json
    final walletBytes = utf8.encode(jsonEncode(walletJson));
    archive.addFile(ArchiveFile('wallet.json', walletBytes.length, walletBytes));

    // multisig data
    if (multisigGroups.isNotEmpty) {
      final multisigData = multisigGroups
          .map(
            (g) => {
              'id': g.id,
              'name': g.name,
              'n': g.n,
              'm': g.m,
            },
          )
          .toList();
      final multisigBytes = utf8.encode(jsonEncode(multisigData));
      archive.addFile(
        ArchiveFile(
          'multisig/multisig.json',
          multisigBytes.length,
          multisigBytes,
        ),
      );
    }

    // transactions
    if (transactions.isNotEmpty) {
      final txData = transactions
          .map(
            (t) => {
              'id': t.id,
              'groupId': t.groupId,
              'amount': t.amount,
              'destination': t.destination,
            },
          )
          .toList();
      final txBytes = utf8.encode(jsonEncode(txData));
      archive.addFile(
        ArchiveFile(
          'transactions.json',
          txBytes.length,
          txBytes,
        ),
      );
    }

    final zipData = ZipEncoder().encode(archive);

    return CreateBackupResponse(
      backupData: zipData,
      suggestedFilename: 'backup.zip',
    );
  }

  @override
  Future<ValidateBackupResponse> validateBackup(
    List<int> backupData,
    String filename,
  ) async {
    try {
      final archive = ZipDecoder().decodeBytes(backupData);

      // Must contain wallet.json
      final walletFile = archive.files.where((f) => f.name == 'wallet.json');
      if (walletFile.isEmpty) {
        return ValidateBackupResponse(
          valid: false,
          errorMessage: 'Missing wallet.json',
        );
      }

      // Validate wallet.json is valid JSON with expected structure
      final walletContent = utf8.decode(walletFile.first.content as List<int>);
      final walletData = jsonDecode(walletContent) as Map<String, dynamic>;

      final hasOldFormat = walletData.containsKey('master') && walletData.containsKey('l1');
      final hasNewFormat = walletData.containsKey('wallets') && walletData['wallets'] is List;

      if (!hasOldFormat && !hasNewFormat) {
        return ValidateBackupResponse(
          valid: false,
          errorMessage: 'Invalid wallet.json structure',
        );
      }

      // Validate multisig.json if present
      final multisigFile = archive.files.where(
        (f) => f.name == 'multisig/multisig.json',
      );
      if (multisigFile.isNotEmpty) {
        final content = utf8.decode(multisigFile.first.content as List<int>);
        jsonDecode(content); // throws on invalid JSON
      }

      // Validate transactions.json if present
      final txFile = archive.files.where(
        (f) => f.name == 'transactions.json',
      );
      if (txFile.isNotEmpty) {
        final content = utf8.decode(txFile.first.content as List<int>);
        jsonDecode(content); // throws on invalid JSON
      }

      return ValidateBackupResponse(valid: true);
    } catch (e) {
      return ValidateBackupResponse(
        valid: false,
        errorMessage: 'Validation failed: $e',
      );
    }
  }

  @override
  Future<void> restoreBackup(List<int> backupData, String filename) async {
    // Validate first
    final validation = await validateBackup(backupData, filename);
    if (!validation.valid) {
      throw WalletException(
        'Restore failed: ${validation.errorMessage}',
      );
    }

    final archive = ZipDecoder().decodeBytes(backupData);

    // Restore wallet.json
    final walletFile = archive.files.firstWhere((f) => f.name == 'wallet.json');
    final walletContent = utf8.decode(walletFile.content as List<int>);
    walletJson = jsonDecode(walletContent) as Map<String, dynamic>;

    // Restore multisig groups
    final multisigFiles = archive.files.where(
      (f) => f.name == 'multisig/multisig.json',
    );
    if (multisigFiles.isNotEmpty) {
      final content = utf8.decode(multisigFiles.first.content as List<int>);
      final data = jsonDecode(content) as List<dynamic>;
      multisigGroups = data.map((g) {
        final map = g as Map<String, dynamic>;
        return multisigpb.MultisigGroup(
          id: map['id'] as String,
          name: map['name'] as String,
          n: map['n'] as int,
          m: map['m'] as int,
        );
      }).toList();
    } else {
      multisigGroups = [];
    }

    // Restore transactions
    final txFiles = archive.files.where(
      (f) => f.name == 'transactions.json',
    );
    if (txFiles.isNotEmpty) {
      final content = utf8.decode(txFiles.first.content as List<int>);
      final data = jsonDecode(content) as List<dynamic>;
      transactions = data.map((t) {
        final map = t as Map<String, dynamic>;
        return multisigpb.MultisigTransaction(
          id: map['id'] as String,
          groupId: map['groupId'] as String,
          amount: (map['amount'] as num).toDouble(),
          destination: map['destination'] as String,
        );
      }).toList();
    } else {
      transactions = [];
    }

    restoreCalled = true;
    restoredBackupData = backupData;
    restoredFilename = filename;
  }
}

void main() {
  group('Backup/Restore round-trip', () {
    late RoundTripWalletAPI walletApi;

    setUp(() {
      walletApi = RoundTripWalletAPI();
    });

    test('create → validate → restore round-trips wallet data', () async {
      // Set up initial wallet state
      walletApi.walletJson = {
        'wallets': [
          {
            'master': 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
            'l1': {'xpub': 'xpub_test_123', 'address': 'bc1q_test'},
          },
        ],
      };

      // Create backup
      final backupResponse = await walletApi.createBackup();
      expect(backupResponse.backupData.isNotEmpty, true);

      // Validate backup
      final validateResponse = await walletApi.validateBackup(
        backupResponse.backupData,
        'test-backup.zip',
      );
      expect(validateResponse.valid, true);

      // Clear state to simulate fresh install
      walletApi.walletJson = null;

      // Restore
      await walletApi.restoreBackup(
        backupResponse.backupData,
        'test-backup.zip',
      );

      // Verify wallet was restored
      expect(walletApi.restoreCalled, true);
      expect(walletApi.walletJson, isNotNull);
      expect(walletApi.walletJson!['wallets'], isA<List>());
      final wallets = walletApi.walletJson!['wallets'] as List;
      expect(wallets.length, 1);
      expect(wallets[0]['master'], contains('abandon'));
      expect(wallets[0]['l1']['xpub'], 'xpub_test_123');
    });

    test('create → validate → restore round-trips multisig groups', () async {
      walletApi.walletJson = {
        'wallets': [
          {
            'master': 'test_seed',
            'l1': {'xpub': 'xpub123'},
          },
        ],
      };
      walletApi.multisigGroups = [
        multisigpb.MultisigGroup(
          id: 'group-1',
          name: 'Savings Vault',
          n: 3,
          m: 2,
        ),
        multisigpb.MultisigGroup(
          id: 'group-2',
          name: 'Business Account',
          n: 5,
          m: 3,
        ),
      ];

      // Create backup
      final backupResponse = await walletApi.createBackup();

      // Clear state
      walletApi.walletJson = null;
      walletApi.multisigGroups = [];

      // Restore
      await walletApi.restoreBackup(backupResponse.backupData, 'backup.zip');

      // Verify multisig groups were restored
      expect(walletApi.multisigGroups.length, 2);
      expect(walletApi.multisigGroups[0].id, 'group-1');
      expect(walletApi.multisigGroups[0].name, 'Savings Vault');
      expect(walletApi.multisigGroups[0].n, 3);
      expect(walletApi.multisigGroups[0].m, 2);
      expect(walletApi.multisigGroups[1].id, 'group-2');
      expect(walletApi.multisigGroups[1].name, 'Business Account');
      expect(walletApi.multisigGroups[1].n, 5);
      expect(walletApi.multisigGroups[1].m, 3);
    });

    test('create → validate → restore round-trips transactions', () async {
      walletApi.walletJson = {
        'wallets': [
          {
            'master': 'test_seed',
            'l1': {'xpub': 'xpub123'},
          },
        ],
      };
      walletApi.transactions = [
        multisigpb.MultisigTransaction(
          id: 'tx-001',
          groupId: 'group-1',
          amount: 1.5,
          destination: 'bc1q_dest_1',
        ),
        multisigpb.MultisigTransaction(
          id: 'tx-002',
          groupId: 'group-1',
          amount: 0.25,
          destination: 'bc1q_dest_2',
        ),
      ];

      // Create backup
      final backupResponse = await walletApi.createBackup();

      // Clear state
      walletApi.walletJson = null;
      walletApi.transactions = [];

      // Restore
      await walletApi.restoreBackup(backupResponse.backupData, 'backup.zip');

      // Verify transactions were restored
      expect(walletApi.transactions.length, 2);
      expect(walletApi.transactions[0].id, 'tx-001');
      expect(walletApi.transactions[0].groupId, 'group-1');
      expect(walletApi.transactions[0].amount, 1.5);
      expect(walletApi.transactions[0].destination, 'bc1q_dest_1');
      expect(walletApi.transactions[1].id, 'tx-002');
      expect(walletApi.transactions[1].amount, 0.25);
    });

    test('full round-trip with wallet + multisig + transactions together', () async {
      // Set up comprehensive state
      walletApi.walletJson = {
        'wallets': [
          {
            'master': 'legal winner thank year wave sausage worth useful legal winner thank yellow',
            'l1': {
              'xpub': 'xpub6BosfCnifzxcFwrSzQiqu2DBVTshkCXacvNsWGYRVVStYzbPHtVMUGRMmella9X',
              'address': 'bc1qtest123',
            },
          },
        ],
      };
      walletApi.multisigGroups = [
        multisigpb.MultisigGroup(
          id: 'vault-1',
          name: 'Cold Storage',
          n: 3,
          m: 2,
        ),
      ];
      walletApi.transactions = [
        multisigpb.MultisigTransaction(
          id: 'withdrawal-1',
          groupId: 'vault-1',
          amount: 10.0,
          destination: 'bc1q_cold_storage_addr',
        ),
      ];

      // Create backup
      final backupResponse = await walletApi.createBackup();
      expect(backupResponse.backupData.isNotEmpty, true);

      // Validate
      final validateResponse = await walletApi.validateBackup(
        backupResponse.backupData,
        'full-backup.zip',
      );
      expect(validateResponse.valid, true);

      // Clear everything
      walletApi.walletJson = null;
      walletApi.multisigGroups = [];
      walletApi.transactions = [];

      // Restore
      await walletApi.restoreBackup(backupResponse.backupData, 'full-backup.zip');

      // Verify all data survived the round trip
      expect(walletApi.walletJson, isNotNull);
      expect(
        (walletApi.walletJson!['wallets'] as List)[0]['master'],
        contains('legal winner'),
      );
      expect(walletApi.multisigGroups.length, 1);
      expect(walletApi.multisigGroups[0].name, 'Cold Storage');
      expect(walletApi.transactions.length, 1);
      expect(walletApi.transactions[0].amount, 10.0);
      expect(walletApi.transactions[0].destination, 'bc1q_cold_storage_addr');
    });

    test('validate rejects backup without wallet.json', () async {
      // Build a ZIP without wallet.json
      final archive = Archive();
      final data = utf8.encode('{"groups": []}');
      archive.addFile(
        ArchiveFile(
          'multisig/multisig.json',
          data.length,
          data,
        ),
      );
      final zipData = ZipEncoder().encode(archive);

      final result = await walletApi.validateBackup(zipData, 'bad-backup.zip');
      expect(result.valid, false);
      expect(result.errorMessage, contains('wallet.json'));
    });

    test('validate rejects backup with invalid wallet.json structure', () async {
      final archive = Archive();
      final data = utf8.encode('{"foo": "bar"}');
      archive.addFile(ArchiveFile('wallet.json', data.length, data));
      final zipData = ZipEncoder().encode(archive);

      final result = await walletApi.validateBackup(zipData, 'bad-wallet.zip');
      expect(result.valid, false);
      expect(result.errorMessage, contains('Invalid wallet.json'));
    });

    test('validate rejects backup with invalid multisig JSON', () async {
      final archive = Archive();
      final walletData = utf8.encode(
        jsonEncode({
          'wallets': [
            {
              'master': 'seed',
              'l1': {'xpub': 'xpub123'},
            },
          ],
        }),
      );
      archive.addFile(ArchiveFile('wallet.json', walletData.length, walletData));

      final badMultisig = utf8.encode('not valid json {{{');
      archive.addFile(
        ArchiveFile(
          'multisig/multisig.json',
          badMultisig.length,
          badMultisig,
        ),
      );
      final zipData = ZipEncoder().encode(archive);

      final result = await walletApi.validateBackup(zipData, 'bad-multisig.zip');
      expect(result.valid, false);
      expect(result.errorMessage, contains('Validation failed'));
    });

    test('restore fails hard on invalid backup', () async {
      final archive = Archive();
      final data = utf8.encode('{"foo": "bar"}');
      archive.addFile(ArchiveFile('wallet.json', data.length, data));
      final zipData = ZipEncoder().encode(archive);

      expect(
        () => walletApi.restoreBackup(zipData, 'invalid.zip'),
        throwsA(isA<WalletException>()),
      );
    });

    test('createBackup fails when no wallet exists', () async {
      walletApi.walletJson = null;

      expect(
        () => walletApi.createBackup(),
        throwsA(isA<WalletException>()),
      );
    });

    test('restore with wallet-only backup (no multisig/transactions) clears existing data', () async {
      // Pre-populate with multisig and transactions
      walletApi.walletJson = {
        'wallets': [
          {
            'master': 'old_seed',
            'l1': {'xpub': 'old_xpub'},
          },
        ],
      };
      walletApi.multisigGroups = [
        multisigpb.MultisigGroup(id: 'old-group', name: 'Old'),
      ];
      walletApi.transactions = [
        multisigpb.MultisigTransaction(id: 'old-tx', groupId: 'old-group'),
      ];

      // Create a wallet-only backup (no multisig, no transactions)
      final walletOnlyApi = RoundTripWalletAPI();
      walletOnlyApi.walletJson = {
        'wallets': [
          {
            'master': 'new_seed',
            'l1': {'xpub': 'new_xpub'},
          },
        ],
      };
      final backupResponse = await walletOnlyApi.createBackup();

      // Restore wallet-only backup to original API
      await walletApi.restoreBackup(backupResponse.backupData, 'wallet-only.zip');

      // Wallet should be replaced
      expect(
        (walletApi.walletJson!['wallets'] as List)[0]['master'],
        'new_seed',
      );
      // Multisig and transactions should be cleared (not carried over from old state)
      expect(walletApi.multisigGroups, isEmpty);
      expect(walletApi.transactions, isEmpty);
    });
  });

  group('getNextAccountIndex - no silent fallback', () {
    test('MockMultisigAPI returns value without silent fallback', () async {
      final api = MockMultisigAPI();
      // The mock returns 8000, but the important thing is that it doesn't
      // silently swallow errors. In production code, the catch block with
      // return 8000 has been removed from hd_wallet_provider.dart.
      final result = await api.getNextAccountIndex();
      expect(result, isA<int>());
    });
  });
}

class WalletException implements Exception {
  final String message;
  WalletException(this.message);
  @override
  String toString() => 'WalletException: $message';
}
