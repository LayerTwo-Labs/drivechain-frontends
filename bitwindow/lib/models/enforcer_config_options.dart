enum EnforcerConfigInputType {
  boolean,
  text,
  url,
}

class EnforcerConfigOption {
  final String key;
  final String category;
  final String description;
  final String tooltip;
  final EnforcerConfigInputType inputType;
  final bool isUseful;
  final dynamic defaultValue;
  final bool isReadOnly;

  const EnforcerConfigOption({
    required this.key,
    required this.category,
    required this.description,
    required this.tooltip,
    required this.inputType,
    this.isUseful = false,
    this.defaultValue,
    this.isReadOnly = false,
  });
}

class EnforcerConfigOptions {
  static const List<EnforcerConfigOption> allOptions = [
    // General Options
    EnforcerConfigOption(
      key: 'enable-wallet',
      category: 'General',
      description: 'Enable Wallet',
      tooltip: 'Enable wallet functionality in the enforcer. This allows the enforcer to manage mainchain addresses.',
      inputType: EnforcerConfigInputType.boolean,
      isUseful: true,
      defaultValue: true,
    ),
    EnforcerConfigOption(
      key: 'enable-mempool',
      category: 'General',
      description: 'Enable Mempool',
      tooltip:
          'Enable mempool support in the enforcer. This is required for getblocktemplate support and mining functionality.',
      inputType: EnforcerConfigInputType.boolean,
      isUseful: true,
      defaultValue: true,
    ),

    // Network Options
    EnforcerConfigOption(
      key: 'wallet-esplora-url',
      category: 'Network',
      description: 'Esplora API URL',
      tooltip:
          'URL of the Esplora API to use for wallet functionality. Leave empty to use the network-specific default (e.g., mempool.space for mainnet/forknet, localhost:3002 for regtest).',
      inputType: EnforcerConfigInputType.url,
      isUseful: true,
    ),

    // Node RPC Options (read-only, inherited from Bitcoin Core)
    EnforcerConfigOption(
      key: 'node-rpc-addr',
      category: 'Node RPC',
      description: 'Node RPC Address',
      tooltip:
          'RPC address of the Bitcoin Core node. This is automatically inherited from your Bitcoin Core configuration.',
      inputType: EnforcerConfigInputType.text,
      isReadOnly: true,
    ),
    EnforcerConfigOption(
      key: 'node-rpc-user',
      category: 'Node RPC',
      description: 'Node RPC User',
      tooltip:
          'RPC username for connecting to Bitcoin Core. This is automatically inherited from your Bitcoin Core configuration.',
      inputType: EnforcerConfigInputType.text,
      isReadOnly: true,
    ),
    EnforcerConfigOption(
      key: 'node-rpc-pass',
      category: 'Node RPC',
      description: 'Node RPC Password',
      tooltip:
          'RPC password for connecting to Bitcoin Core. This is automatically inherited from your Bitcoin Core configuration.',
      inputType: EnforcerConfigInputType.text,
      isReadOnly: true,
    ),
  ];

  static List<String> get categories {
    return allOptions.map((o) => o.category).toSet().toList()..sort();
  }

  static List<EnforcerConfigOption> getByCategory(String category) {
    return allOptions.where((o) => o.category == category).toList();
  }

  static List<EnforcerConfigOption> get usefulOptions {
    return allOptions.where((o) => o.isUseful).toList();
  }

  static List<EnforcerConfigOption> get editableOptions {
    return allOptions.where((o) => !o.isReadOnly).toList();
  }

  static EnforcerConfigOption? getByKey(String key) {
    try {
      return allOptions.firstWhere((o) => o.key == key);
    } catch (e) {
      return null;
    }
  }
}
