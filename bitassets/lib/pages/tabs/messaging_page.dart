import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

@RoutePage()
class BitAssetsMessagingPage extends StatelessWidget {
  const BitAssetsMessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rpc = GetIt.I.get<BitAssetsRPC>();
    final provider = GetIt.I.get<BitAssetsProvider>();

    return MessagingView(
      noun: 'BitAsset',
      resolveEncryptionKey: (input) => resolveEncryptionPubkey(
        input,
        [for (final entry in provider.entries) (hash: entry.hash, encryptionPubkey: entry.details.encryptionPubkey)],
        onPlaintextMatch: (plaintext) {
          unawaited(provider.saveHashNameMapping(plaintext));
          unawaited(provider.fetch());
        },
      ),
      encrypt: rpc.encryptMsg,
      decrypt: rpc.decryptMsg,
    );
  }
}
