import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Merkle Tree calculation utilities for Bitcoin blocks
class MerkleTree {
  /// Calculate Merkle tree from transaction IDs
  /// Returns a list of levels, where each level contains hashes
  /// Level 0 is the leaves (TxIDs), last level is the Merkle root
  static List<List<String>> calculate(List<String> txids) {
    if (txids.isEmpty) return [];

    // Parse hex strings to bytes
    final leaves = txids.map((txid) => _hexToBytes(txid)).toList();

    // Build the tree
    final tree = <List<Uint8List>>[];
    tree.add(leaves);

    // Special case: single transaction
    if (leaves.length == 1) {
      return [
        [_bytesToHex(leaves[0])],
      ];
    }

    // Build levels until we reach the root
    while (tree.last.length > 1) {
      final currentLevel = tree.last;
      final nextLevel = <Uint8List>[];

      for (int i = 0; i < currentLevel.length; i += 2) {
        final hash1 = currentLevel[i];
        // If odd number, duplicate last hash
        final hash2 = i + 1 < currentLevel.length ? currentLevel[i + 1] : hash1;

        // Compute SHA256d of concatenated hashes
        final combined = Uint8List.fromList([...hash1, ...hash2]);
        final product = _sha256d(combined);

        nextLevel.add(product);
      }

      tree.add(nextLevel);
    }

    // Convert to hex strings
    return tree.map((level) => level.map((hash) => _bytesToHex(hash)).toList()).toList();
  }

  /// Calculate Reversed Concatenated Bytes (RCB) for each level
  /// This is used for manual verification with hash calculators
  static List<List<String>> calculateRCB(List<String> txids) {
    if (txids.isEmpty || txids.length == 1) return [];

    final leaves = txids.map((txid) => _hexToBytes(txid)).toList();
    final tree = <List<Uint8List>>[];
    tree.add(leaves);

    // Build tree
    while (tree.last.length > 1) {
      final currentLevel = tree.last;
      final nextLevel = <Uint8List>[];

      for (int i = 0; i < currentLevel.length; i += 2) {
        final hash1 = currentLevel[i];
        final hash2 = i + 1 < currentLevel.length ? currentLevel[i + 1] : hash1;
        final combined = Uint8List.fromList([...hash1, ...hash2]);
        final product = _sha256d(combined);
        nextLevel.add(product);
      }

      tree.add(nextLevel);
    }

    // Make all levels even for RCB
    final evenTree = tree.map((level) {
      if (level.length % 2 != 0) {
        return [...level, level.last];
      }
      return level;
    }).toList();

    // Generate RCB strings
    final rcbTree = <List<String>>[];
    for (final level in evenTree.reversed) {
      if (level.length < 2) continue;

      final rcbLevel = <String>[];
      for (int i = 0; i < level.length; i += 2) {
        final hash1 = Uint8List.fromList(level[i].reversed.toList());
        final hash2 = Uint8List.fromList(level[i + 1].reversed.toList());
        final rcb = _bytesToHex(hash1) + _bytesToHex(hash2);
        rcbLevel.add(rcb);
      }

      rcbTree.insert(0, rcbLevel);
    }

    return rcbTree;
  }

  /// Double SHA-256 hash
  static Uint8List _sha256d(Uint8List data) {
    final firstHash = sha256.convert(data).bytes;
    final secondHash = sha256.convert(firstHash).bytes;
    return Uint8List.fromList(secondHash);
  }

  /// Convert hex string to bytes
  static Uint8List _hexToBytes(String hex) {
    final clean = hex.replaceAll(' ', '').replaceAll('\n', '');
    final bytes = <int>[];
    for (int i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  /// Convert bytes to hex string
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  /// Format tree as text for display (similar to Qt version)
  static String formatTreeText(List<List<String>> tree, {List<List<String>>? rcbTree}) {
    if (tree.isEmpty) return 'No transactions provided';

    final buffer = StringBuffer();
    buffer.writeln('Merkle Tree for block header hashMerkleRoot:\n');

    // Display from root to leaves
    for (int levelNum = tree.length - 1; levelNum >= 0; levelNum--) {
      final level = tree[levelNum];

      buffer.write('Level $levelNum');
      if (levelNum == tree.length - 1) {
        buffer.writeln(' Merkle Root:');
      } else if (levelNum == 0) {
        buffer.writeln(' (TxID):');
      } else {
        buffer.writeln(':');
      }

      buffer.write('     ');

      // Add hashes with comma between pairs
      int nodeCount = 0;
      for (int i = 0; i < level.length; i++) {
        nodeCount++;

        if (nodeCount == 2 && i != level.length - 1) {
          buffer.write('${level[i]}, ');
        } else {
          buffer.write('${level[i]} ');
        }

        if (nodeCount == 2) {
          nodeCount = 0;
        }
      }

      // Add RCB for this level if available
      if (rcbTree != null && levelNum < rcbTree.length && levelNum != tree.length - 1) {
        buffer.write('\nRCB: ');
        for (int i = 0; i < rcbTree[levelNum].length; i++) {
          if (i == rcbTree[levelNum].length - 1) {
            buffer.write('${rcbTree[levelNum][i]}\n');
          } else {
            buffer.write('${rcbTree[levelNum][i]},  ');
          }
        }
        buffer.writeln();
      } else {
        buffer.writeln('\n');
      }
    }

    return buffer.toString();
  }
}
