import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

class BitwindowConsoleTab extends StatelessWidget {
  const BitwindowConsoleTab({super.key});

  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Debug Console',
      subtitle: 'Execute commands and view responses',
      child: ConsoleView(
        services: [
          ConsoleService(
            name: 'bitcoind',
            commands: mainchain.getMethods(),
            execute: (command, args) => mainchain.callRAW(command, args),
          ),
          ConsoleService(
            name: 'bitwindowd',
            commands: bitwindow.getMethods(),
            execute: (command, args) async {
              String jsonBody = '{}';
              if (args.isNotEmpty) {
                try {
                  json.decode(args[0]).toString();
                  jsonBody = args[0];
                } catch (e) {
                  throw Exception('Arguments must be a single JSON object, e.g. {"key": "value"} $e');
                }
              }
              return await bitwindow.callRAW(command, jsonBody);
            },
          ),
          ConsoleService(
            name: 'enforcer',
            commands: enforcer.getMethods(),
            execute: (command, args) async {
              String jsonBody = '{}';
              if (args.isNotEmpty) {
                try {
                  json.decode(args[0]).toString();
                  jsonBody = args[0];
                } catch (e) {
                  throw Exception('Arguments must be a single JSON object, e.g. {"key": "value"} $e');
                }
              }
              return await bitwindow.callRAW(command, jsonBody);
            },
          ),
        ],
      ),
    );
  }
}
