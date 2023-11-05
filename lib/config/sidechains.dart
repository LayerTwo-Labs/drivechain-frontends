abstract class Sidechain {
  String name = '';
  String ticker = '';
  static const int slot = 0;
}

// TODO: get this from config, RPC, something
class TestSidechain implements Sidechain {
  static const int slot = 1;

  @override
  String name = 'Testchain';

  @override
  String ticker = 'SC1';
}

// TODO: get this from config, RPC, something
class EthereumSidechain implements Sidechain {
  static const int slot = 6;

  @override
  String name = 'Ethereum';

  @override
  String ticker = 'SC6';
}
