/// The one line of freebank.conf that BitWindow edits: `coinbasetag=`, the name
/// a FreeBank node writes into the coinbase of every block it makes, so block
/// explorers can credit the block to it. freebankd reads it at startup only.
library;

import 'dart:math';

const coinbaseTagKey = 'coinbasetag';
const coinbaseTagMaxBytes = 64;

/// The name the conf gives, or null when it sets none. The last line wins, as in
/// Core.
String? readCoinbaseTag(String conf) {
  String? tag;
  for (final line in conf.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.startsWith('$coinbaseTagKey=')) {
      tag = trimmed.substring(coinbaseTagKey.length + 1).trim();
    }
  }
  return tag;
}

/// Why freebankd would refuse this name, or null if it takes it. It mirrors the
/// node's own check (1 to 64 printable ASCII bytes), plus the two things the conf
/// file itself would bend: a `#` starts a comment, and quotes become part of the
/// name.
String? coinbaseTagProblem(String name) {
  final tag = name.trim();
  if (tag.isEmpty) {
    return 'Give a name.';
  }
  if (tag.length > coinbaseTagMaxBytes) {
    return 'Use at most $coinbaseTagMaxBytes characters.';
  }
  for (final unit in tag.codeUnits) {
    if (unit < 0x20 || unit > 0x7e) {
      return 'Use plain letters, digits, punctuation and spaces.';
    }
  }
  if (tag.contains('#')) {
    return 'Leave out #: it starts a comment in freebank.conf.';
  }
  if (tag.startsWith('"') || tag.startsWith("'") || tag.endsWith('"') || tag.endsWith("'")) {
    return 'Leave out the quotes: they would become part of the name.';
  }
  return null;
}

/// The conf with its name set to [name]: an existing `coinbasetag=` line is
/// replaced in place, and every other line is kept as it was.
String setCoinbaseTag(String conf, String name) {
  final line = '$coinbaseTagKey=${name.trim()}';
  final lines = conf.isEmpty ? <String>[] : conf.split('\n');
  final kept = <String>[];
  var replaced = false;
  for (final l in lines) {
    if (l.trim().startsWith('$coinbaseTagKey=')) {
      if (!replaced) {
        kept.add(line);
        replaced = true;
      }
      continue;
    }
    kept.add(l);
  }
  if (!replaced) {
    if (kept.isNotEmpty && kept.last.isEmpty) {
      kept.insert(kept.length - 1, line);
    } else {
      kept.add(line);
    }
  }
  final out = kept.join('\n');
  return out.endsWith('\n') ? out : '$out\n';
}

/// A name to offer a user who has none yet: unique enough to spot their own
/// blocks, it says where they came from, and it carries nothing personal.
String suggestCoinbaseTag([Random? random]) {
  const letters = 'abcdefghjkmnpqrstuvwxyz23456789';
  final rng = random ?? Random.secure();
  final suffix = List.generate(4, (_) => letters[rng.nextInt(letters.length)]).join();
  return 'bitwindow-$suffix';
}
