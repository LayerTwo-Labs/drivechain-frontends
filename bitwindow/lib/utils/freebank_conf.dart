/// The one line of freebank.conf that BitWindow edits: `coinbasetag=`, the name
/// a FreeBank node writes into the coinbase of every block it makes, so block
/// explorers can credit the block to it. freebankd reads it at startup only.
library;

import 'dart:math';

const coinbaseTagKey = 'coinbasetag';
const coinbaseTagMaxBytes = 64;

/// A Core-style network header, for example `[regtest]`. Every line after one
/// belongs to that network only.
final _sectionHeader = RegExp(r'^\[[^\]]*\]$');

/// A `coinbasetag` line. Core takes whitespace around the `=`, so a valid entry
/// reads `coinbasetag = alice` as well.
final _tagLine = RegExp('^$coinbaseTagKey\\s*=\\s*(.*)\$');

/// The network section freebankd reads. BitWindow starts the node with no chain
/// flag, so it runs its default main chain.
const activeNetworkSection = 'main';

/// The name the node takes, or null when the conf sets none. A `[main]` entry
/// beats the global part, and any other network section counts for nothing. The
/// last line of a scope wins, as in Core.
String? readCoinbaseTag(String conf) {
  String? global;
  String? active;
  String? section;
  for (final line in conf.split('\n')) {
    final trimmed = line.trim();
    if (_sectionHeader.hasMatch(trimmed)) {
      section = trimmed.substring(1, trimmed.length - 1);
      continue;
    }
    final tag = _tagLine.firstMatch(trimmed);
    if (tag == null) {
      continue;
    }
    final value = _withoutComment(tag.group(1)!);
    if (section == null) {
      global = value;
    } else if (section == activeNetworkSection) {
      active = value;
    }
  }
  return active ?? global;
}

/// The value without an inline `# comment`, as the node's own conf parser reads
/// it.
String _withoutComment(String value) {
  final hash = value.indexOf('#');
  return (hash < 0 ? value : value.substring(0, hash)).trim();
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

/// The conf with the name the node takes set to [name]. A `[main]` entry beats
/// the global part, so the change goes there when one exists. Otherwise the line
/// goes in the global part, before the first network header. Every other line
/// stays as it was.
String setCoinbaseTag(String conf, String name) {
  final line = '$coinbaseTagKey=${name.trim()}';
  final lines = conf.isEmpty ? <String>[] : conf.split('\n');
  final target = _tagInActiveSection(lines) ? activeNetworkSection : null;

  final kept = <String>[];
  var written = false;
  String? section;
  for (final l in lines) {
    final trimmed = l.trim();
    if (_sectionHeader.hasMatch(trimmed)) {
      if (!written && target == null) {
        kept.add(line);
        written = true;
      }
      section = trimmed.substring(1, trimmed.length - 1);
    } else if (section == target && _tagLine.hasMatch(trimmed)) {
      if (!written) {
        kept.add(line);
        written = true;
      }
      continue;
    }
    kept.add(l);
  }
  if (!written) {
    if (kept.isNotEmpty && kept.last.isEmpty) {
      kept.insert(kept.length - 1, line);
    } else {
      kept.add(line);
    }
  }
  final out = kept.join('\n');
  return out.endsWith('\n') ? out : '$out\n';
}

bool _tagInActiveSection(List<String> lines) {
  String? section;
  for (final l in lines) {
    final trimmed = l.trim();
    if (_sectionHeader.hasMatch(trimmed)) {
      section = trimmed.substring(1, trimmed.length - 1);
    } else if (section == activeNetworkSection && _tagLine.hasMatch(trimmed)) {
      return true;
    }
  }
  return false;
}

/// A name to offer a user who has none yet: unique enough to spot their own
/// blocks, it says where they came from, and it carries nothing personal.
String suggestCoinbaseTag([Random? random]) {
  const letters = 'abcdefghjkmnpqrstuvwxyz23456789';
  final rng = random ?? Random.secure();
  final suffix = List.generate(4, (_) => letters[rng.nextInt(letters.length)]).join();
  return 'bitwindow-$suffix';
}
