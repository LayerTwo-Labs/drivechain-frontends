import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

@RoutePage()
class BitnamesMessagingPage extends StatelessWidget {
  const BitnamesMessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rpc = GetIt.I.get<BitnamesRPC>();
    final provider = GetIt.I.get<BitnamesProvider>();

    return MessagingView(
      noun: 'BitName',
      resolveEncryptionKey: (input) => resolveEncryptionPubkey(
        input,
        [for (final entry in provider.entries) (hash: entry.hash, encryptionPubkey: entry.details.encryptionPubkey)],
        onPlaintextMatch: (plaintext) {
          unawaited(provider.saveHashNameMapping(plaintext));
        },
      ),
      encrypt: rpc.encryptMsg,
      decrypt: rpc.decryptMsg,
    );
  }
}
