import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

abstract class Sidechain {
  String name = '';
  int slot = 0;
  Color color = Colors.transparent;
  SidechainType get type;
  String get ticker {
    return 'SC$slot';
  }
}

abstract class SideWithTicker implements Sidechain {
  @override
  String get ticker {
    return 'SC$slot';
  }
}

class TestSidechain extends SideWithTicker {
  @override
  String name = 'Testchain';

  @override
  int slot = 0;

  @override
  Color color = SailColorScheme.orange;

  @override
  SidechainType get type => SidechainType.testChain;
}

class EthereumSidechain extends SideWithTicker {
  @override
  String name = 'Ethereum';

  @override
  int slot = 6;

  @override
  Color color = SailColorScheme.purple;

  @override
  SidechainType get type => SidechainType.ethereum;
}

enum SidechainType { testChain, ethereum }
