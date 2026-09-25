import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// The catalog the orchestrator compiles in. Its first eCash row is what the
/// backend answers before the published catalog loads.
Map<String, dynamic> _embeddedECash() {
  final file = File('../sidechain-orchestrator/config/netcatalog/networks.json');
  final catalog = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final networks = (catalog['networks'] as List).cast<Map<String, dynamic>>();
  return networks.firstWhere((n) => n['family'] == 'ecash');
}

String _backendURL(Map<String, dynamic> network, String kind) {
  final backends = (network['backends'] as List).cast<Map<String, dynamic>>();
  final of = backends.where((b) => b['kind'] == kind).toList()
    ..sort((a, b) => ((a['priority'] as int?) ?? 0).compareTo((b['priority'] as int?) ?? 0));
  return of.first['url'] as String;
}

void main() {
  // No provider is registered, so each helper answers with the value this
  // build shipped with. A build that names the outgoing network here runs the
  // wrong preset over the new chain, which is how a user loses a balance.
  final ecash = _embeddedECash();

  test('the network id falls back to the compiled-in eCash network', () {
    expect(ecashNetworkId(), ecash['id']);
  });

  test('the esplora URL falls back to the compiled-in one', () {
    expect(ecashEsploraUrl(), _backendURL(ecash, 'esplora'));
  });

  test('the explorer host falls back to the compiled-in one', () {
    expect(ecashExplorerHost(), Uri.parse(ecash['explorer_tx_template'] as String).host);
  });
}
