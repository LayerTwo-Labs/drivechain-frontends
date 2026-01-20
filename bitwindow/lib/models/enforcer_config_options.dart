enum EnforcerConfigInputType {
  boolean,
  text,
  url,
  number,
  path,
  select, // For enum-like options with predefined values
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
  final List<String>? selectOptions; // For select input type

  const EnforcerConfigOption({
    required this.key,
    required this.category,
    required this.description,
    required this.tooltip,
    required this.inputType,
    this.isUseful = false,
    this.defaultValue,
    this.isReadOnly = false,
    this.selectOptions,
  });
}

class EnforcerConfigOptions {
  static const List<EnforcerConfigOption> allOptions = [
    // ===================
    // General Options
    // ===================
    EnforcerConfigOption(
      key: 'data-dir',
      category: 'General',
      description: 'Data Directory',
      tooltip: 'Directory to store wallet + drivechain + validator data.',
      inputType: EnforcerConfigInputType.path,
    ),
    EnforcerConfigOption(
      key: 'enable-wallet',
      category: 'General',
      description: 'Enable Wallet',
      tooltip: 'Enable wallet functionality in the enforcer.',
      inputType: EnforcerConfigInputType.boolean,
      isUseful: true,
      defaultValue: true,
    ),
    EnforcerConfigOption(
      key: 'enable-mempool',
      category: 'General',
      description: 'Enable Mempool',
      tooltip: 'If enabled, maintains a mempool. If the wallet is enabled, serves getblocktemplate.',
      inputType: EnforcerConfigInputType.boolean,
      isUseful: true,
      defaultValue: true,
    ),

    // ===================
    // Logging Options
    // ===================
    EnforcerConfigOption(
      key: 'log-format',
      category: 'Logging',
      description: 'Log Format',
      tooltip: 'Format for log output.',
      inputType: EnforcerConfigInputType.select,
      selectOptions: ['compact', 'full', 'json', 'pretty'],
      defaultValue: 'compact',
    ),
    EnforcerConfigOption(
      key: 'log-level',
      category: 'Logging',
      description: 'Log Level',
      tooltip:
          'Log level. Logs from most dependencies are filtered one level below the specified log level. Logger output is further configurable via the RUST_LOG environment variable.',
      inputType: EnforcerConfigInputType.select,
      selectOptions: ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR'],
      defaultValue: 'DEBUG',
    ),
    EnforcerConfigOption(
      key: 'max-log-files',
      category: 'Logging',
      description: 'Max Log Files',
      tooltip: 'Maximum number of log files to retain. Older log files will be deleted.',
      inputType: EnforcerConfigInputType.number,
      defaultValue: 10,
    ),
    EnforcerConfigOption(
      key: 'max-log-file-size-mb',
      category: 'Logging',
      description: 'Max Log File Size (MB)',
      tooltip: 'Maximum size of a log file in megabytes. If exceeded, the log file will be rotated.',
      inputType: EnforcerConfigInputType.number,
      defaultValue: 100,
    ),
    EnforcerConfigOption(
      key: 'log-directory',
      category: 'Logging',
      description: 'Log Directory',
      tooltip: 'Directory for log files.',
      inputType: EnforcerConfigInputType.path,
    ),
    EnforcerConfigOption(
      key: 'log-rotation',
      category: 'Logging',
      description: 'Log Rotation',
      tooltip: 'Log file rotation frequency. If set, a new log file will be created at the specified interval.',
      inputType: EnforcerConfigInputType.select,
      selectOptions: ['never', 'daily', 'hourly', 'minutely'],
      defaultValue: 'never',
    ),

    // ===================
    // Node RPC Options
    // ===================
    EnforcerConfigOption(
      key: 'node-rpc-addr',
      category: 'Node RPC',
      description: 'Node RPC Address',
      tooltip: 'Bitcoin Core RPC address. Automatically inherited from your Bitcoin Core configuration.',
      inputType: EnforcerConfigInputType.text,
      isReadOnly: true,
      defaultValue: '127.0.0.1:18443',
    ),
    EnforcerConfigOption(
      key: 'node-rpc-cookie-path',
      category: 'Node RPC',
      description: 'Cookie Path',
      tooltip: 'Path to Bitcoin Core cookie file. Cannot be set together with user + password.',
      inputType: EnforcerConfigInputType.path,
    ),
    EnforcerConfigOption(
      key: 'node-rpc-user',
      category: 'Node RPC',
      description: 'RPC User',
      tooltip: 'RPC username for Bitcoin Core. Automatically inherited from your Bitcoin Core configuration.',
      inputType: EnforcerConfigInputType.text,
      isReadOnly: true,
    ),
    EnforcerConfigOption(
      key: 'node-rpc-pass',
      category: 'Node RPC',
      description: 'RPC Password',
      tooltip: 'RPC password for Bitcoin Core. Automatically inherited from your Bitcoin Core configuration.',
      inputType: EnforcerConfigInputType.text,
      isReadOnly: true,
    ),
    EnforcerConfigOption(
      key: 'node-blocks-dir',
      category: 'Node RPC',
      description: 'Blocks Directory',
      tooltip: 'Path to the Bitcoin Core blocks directory.',
      inputType: EnforcerConfigInputType.path,
    ),
    EnforcerConfigOption(
      key: 'node-zmq-addr-sequence',
      category: 'Node RPC',
      description: 'ZMQ Sequence Address',
      tooltip:
          'Bitcoin node ZMQ endpoint for `sequence`. If not set, the enforcer tries to find it via bitcoin-cli getzmqnotifications.',
      inputType: EnforcerConfigInputType.text,
    ),

    // ===================
    // Server Options
    // ===================
    EnforcerConfigOption(
      key: 'serve-rpc-addr',
      category: 'Server',
      description: 'RPC Address',
      tooltip: 'Address to serve RPCs such as getblocktemplate.',
      inputType: EnforcerConfigInputType.text,
      defaultValue: '127.0.0.1:8122',
    ),
    EnforcerConfigOption(
      key: 'serve-json-rpc-addr',
      category: 'Server',
      description: 'JSON-RPC Address',
      tooltip: 'Address to serve other JSON-RPC methods.',
      inputType: EnforcerConfigInputType.text,
      defaultValue: '127.0.0.1:8123',
    ),
    EnforcerConfigOption(
      key: 'serve-grpc-addr',
      category: 'Server',
      description: 'gRPC Address',
      tooltip: 'Address to serve gRPCs.',
      inputType: EnforcerConfigInputType.text,
      defaultValue: '127.0.0.1:50051',
    ),

    // ===================
    // Wallet Options
    // ===================
    EnforcerConfigOption(
      key: 'wallet-full-scan',
      category: 'Wallet',
      description: 'Full Scan on Startup',
      tooltip:
          'If true, the wallet will perform a full scan of the blockchain on startup, before proceeding with normal operations.',
      inputType: EnforcerConfigInputType.boolean,
      defaultValue: false,
    ),
    EnforcerConfigOption(
      key: 'wallet-auto-create',
      category: 'Wallet',
      description: 'Auto Create Wallet',
      tooltip:
          'If no existing wallet is found, automatically create and load a new, unencrypted wallet from a randomly generated BIP39 mnemonic.',
      inputType: EnforcerConfigInputType.boolean,
      defaultValue: false,
    ),
    EnforcerConfigOption(
      key: 'wallet-esplora-url',
      category: 'Wallet',
      description: 'Esplora API URL',
      tooltip:
          'URL of the Esplora server to use for the wallet. Network defaults: Signet: https://explorer.signet.drivechain.info/api, Mainnet: https://explorer.forknet.drivechain.info/api, Regtest: http://localhost:3003',
      inputType: EnforcerConfigInputType.url,
      isUseful: true,
    ),
    EnforcerConfigOption(
      key: 'wallet-electrum-host',
      category: 'Wallet',
      description: 'Electrum Host',
      tooltip:
          'Electrum server host. Network defaults: Signet: node.signet.drivechain.info, Mainnet: node.forknet.drivechain.info, Regtest: 127.0.0.1',
      inputType: EnforcerConfigInputType.text,
    ),
    EnforcerConfigOption(
      key: 'wallet-electrum-port',
      category: 'Wallet',
      description: 'Electrum Port',
      tooltip: 'Electrum server port. Network defaults: Signet: 50001, Regtest: 60401',
      inputType: EnforcerConfigInputType.number,
    ),
    EnforcerConfigOption(
      key: 'wallet-skip-periodic-sync',
      category: 'Wallet',
      description: 'Skip Periodic Sync',
      tooltip: 'Skip the periodic wallet sync task. Useful if the wallet is large and periodic syncs are not feasible.',
      inputType: EnforcerConfigInputType.boolean,
      defaultValue: false,
    ),
    EnforcerConfigOption(
      key: 'wallet-sync-source',
      category: 'Wallet',
      description: 'Sync Source',
      tooltip:
          'The source of the wallet sync. Electrum: Electrum protocol, Esplora: REST to Esplora server (mempool.space API), Disabled: Only synced by new blocks.',
      inputType: EnforcerConfigInputType.select,
      selectOptions: ['esplora', 'electrum', 'disabled'],
      defaultValue: 'esplora',
      isUseful: true,
    ),
    EnforcerConfigOption(
      key: 'wallet-seed-file',
      category: 'Wallet',
      description: 'Seed File Path',
      tooltip: 'Path to a file containing exactly 12 space-separated BIP39 mnemonic words.',
      inputType: EnforcerConfigInputType.path,
    ),

    // ===================
    // Signet Miner Options
    // ===================
    EnforcerConfigOption(
      key: 'signet-miner-script-path',
      category: 'Signet Miner',
      description: 'Mining Script Path',
      tooltip: 'Path to the Python mining script from Bitcoin Core. If not set, downloaded from GitHub.',
      inputType: EnforcerConfigInputType.path,
    ),
    EnforcerConfigOption(
      key: 'signet-miner-script-debug',
      category: 'Signet Miner',
      description: 'Debug Mode',
      tooltip: 'If true, the signet mining script is run with --debug flag.',
      inputType: EnforcerConfigInputType.boolean,
      defaultValue: false,
    ),
    EnforcerConfigOption(
      key: 'signet-miner-bitcoin-util-path',
      category: 'Signet Miner',
      description: 'bitcoin-util Path',
      tooltip: 'Path to the Bitcoin Core bitcoin-util binary.',
      inputType: EnforcerConfigInputType.path,
      defaultValue: 'bitcoin-util',
    ),
    EnforcerConfigOption(
      key: 'signet-miner-bitcoin-cli-path',
      category: 'Signet Miner',
      description: 'bitcoin-cli Path',
      tooltip: 'Path to the Bitcoin Core bitcoin-cli binary.',
      inputType: EnforcerConfigInputType.path,
      defaultValue: 'bitcoin-cli',
    ),
    EnforcerConfigOption(
      key: 'signet-miner-coinbase-recipient',
      category: 'Signet Miner',
      description: 'Coinbase Recipient',
      tooltip: 'Address for block reward payment.',
      inputType: EnforcerConfigInputType.text,
    ),

    // ===================
    // Advanced Options
    // ===================
    EnforcerConfigOption(
      key: 'exit-after-sync',
      category: 'Advanced',
      description: 'Exit After Sync',
      tooltip:
          'Exit after syncing to the specified block height. If set to 0, exit after syncing to the tip. Can be used for benchmarking sync speeds.',
      inputType: EnforcerConfigInputType.number,
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
