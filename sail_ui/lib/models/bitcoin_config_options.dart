enum ConfigInputType {
  dropdown,
  boolean,
  file,
  directory,
  bitcoinAmount,
  number,
  text,
  command,
  ipAddress,
  network,
}

class BitcoinConfigOption {
  final String key;
  final String category;
  final String description;
  final String tooltip;
  final ConfigInputType inputType;
  final bool isUseful;
  final dynamic defaultValue;
  final List<String>? dropdownValues;
  final String? unit;
  final int? min;
  final int? max;

  const BitcoinConfigOption({
    required this.key,
    required this.category,
    required this.description,
    required this.tooltip,
    required this.inputType,
    this.isUseful = false,
    this.defaultValue,
    this.dropdownValues,
    this.unit,
    this.min,
    this.max,
  });
}

class BitcoinConfigOptions {
  static const List<BitcoinConfigOption> allOptions = [
    // General Options
    BitcoinConfigOption(
      key: 'datadir',
      category: 'General',
      description: 'Data Directory',
      tooltip: 'Specify data directory',
      inputType: ConfigInputType.directory,
      isUseful: true,
    ),
    BitcoinConfigOption(
      key: 'conf',
      category: 'General',
      description: 'Configuration File',
      tooltip:
          'Specify path to read-only configuration file. Relative paths will be prefixed by datadir location (default: bitcoin.conf)',
      inputType: ConfigInputType.file,
    ),
    BitcoinConfigOption(
      key: 'daemon',
      category: 'General',
      description: 'Run as Daemon',
      tooltip: 'Run in the background as a daemon and accept commands (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'txindex',
      category: 'General',
      description: 'Transaction Index',
      tooltip: 'Maintain a full transaction index, used by the getrawtransaction rpc call (default: 0)',
      inputType: ConfigInputType.boolean,
      isUseful: true,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'prune',
      category: 'General',
      description: 'Prune Mode',
      tooltip:
          'Reduce storage requirements by enabling pruning (deleting) of old blocks. This allows the pruneblockchain RPC to be called to delete specific blocks and enables automatic pruning of old blocks if a target size in MiB is provided. (default: 0 = disable pruning blocks, 1 = allow manual pruning via RPC, >=550 = automatically prune block files)',
      inputType: ConfigInputType.number,
      defaultValue: 0,
      min: 0,
      unit: 'MiB',
    ),
    BitcoinConfigOption(
      key: 'dbcache',
      category: 'General',
      description: 'Database Cache Size',
      tooltip:
          'Maximum database cache size <n> MiB (minimum 4, default: 450). Make sure you have enough RAM. In addition, unused memory allocated to the mempool is shared with this cache (see -maxmempool).',
      inputType: ConfigInputType.number,
      defaultValue: 450,
      min: 4,
      unit: 'MiB',
    ),
    BitcoinConfigOption(
      key: 'assumevalid',
      category: 'General',
      description: 'Assume Valid Block',
      tooltip:
          'If this block is in the chain assume that it and its ancestors are valid and potentially skip their script verification (0 to verify all)',
      inputType: ConfigInputType.text,
    ),
    BitcoinConfigOption(
      key: 'blocksdir',
      category: 'General',
      description: 'Blocks Directory',
      tooltip: 'Specify directory to hold blocks subdirectory for *.dat files (default: <datadir>)',
      inputType: ConfigInputType.directory,
    ),
    BitcoinConfigOption(
      key: 'maxmempool',
      category: 'General',
      description: 'Max Mempool Size',
      tooltip: 'Keep the transaction memory pool below <n> megabytes (default: 300)',
      inputType: ConfigInputType.number,
      defaultValue: 300,
      min: 1,
      unit: 'MB',
    ),
    BitcoinConfigOption(
      key: 'par',
      category: 'General',
      description: 'Script Verification Threads',
      tooltip:
          'Set the number of script verification threads (0 = auto, up to 15, <0 = leave that many cores free, default: 0)',
      inputType: ConfigInputType.number,
      defaultValue: 0,
      min: -15,
      max: 15,
    ),
    BitcoinConfigOption(
      key: 'pid',
      category: 'General',
      description: 'PID File',
      tooltip:
          'Specify pid file. Relative paths will be prefixed by a net-specific datadir location. (default: bitcoind.pid)',
      inputType: ConfigInputType.file,
      defaultValue: 'bitcoind.pid',
    ),

    // Connection Options
    BitcoinConfigOption(
      key: 'addnode',
      category: 'Connection',
      description: 'Add Node',
      tooltip:
          'Add a node to connect to and attempt to keep the connection open. This option can be specified multiple times to add multiple nodes; connections are limited to 8 at a time and are counted separately from the -maxconnections limit.',
      inputType: ConfigInputType.ipAddress,
    ),
    BitcoinConfigOption(
      key: 'maxconnections',
      category: 'Connection',
      description: 'Max Connections',
      tooltip:
          'Maintain at most <n> automatic connections to peers (default: 125). This limit does not apply to connections manually added via -addnode or the addnode RPC, which have a separate limit of 8.',
      inputType: ConfigInputType.number,
      defaultValue: 125,
      min: 0,
    ),
    BitcoinConfigOption(
      key: 'port',
      category: 'Connection',
      description: 'Listen Port',
      tooltip:
          'Listen for connections on <port> (default: 8333, testnet3: 18333, testnet4: 48333, signet: 38333, regtest: 18444). Not relevant for I2P. If set to a value x, the default onion listening port will be set to x+1.',
      inputType: ConfigInputType.number,
      isUseful: true,
      defaultValue: 8333,
      min: 1,
      max: 65535,
    ),
    BitcoinConfigOption(
      key: 'listen',
      category: 'Connection',
      description: 'Accept Connections',
      tooltip: 'Accept connections from outside (default: 1 if no -proxy, -connect or -maxconnections=0)',
      inputType: ConfigInputType.boolean,
      isUseful: true,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'connect',
      category: 'Connection',
      description: 'Connect Only To',
      tooltip:
          'Connect only to the specified node; -noconnect disables automatic connections. This option can be specified multiple times to connect to multiple nodes.',
      inputType: ConfigInputType.ipAddress,
    ),
    BitcoinConfigOption(
      key: 'bind',
      category: 'Connection',
      description: 'Bind Address',
      tooltip:
          'Bind to given address and always listen on it (default: 0.0.0.0). Use [host]:port notation for IPv6. Append =onion to tag any incoming connections.',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'proxy',
      category: 'Connection',
      description: 'SOCKS5 Proxy',
      tooltip:
          'Connect through SOCKS5 proxy, set -noproxy to disable (default: disabled). May be a local file path prefixed with "unix:" if the proxy supports it.',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'discover',
      category: 'Connection',
      description: 'Discover Own IP',
      tooltip: 'Discover own IP addresses (default: 1 when listening and no -externalip or -proxy)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'dns',
      category: 'Connection',
      description: 'Allow DNS Lookups',
      tooltip: 'Allow DNS lookups for -addnode, -seednode and -connect (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'dnsseed',
      category: 'Connection',
      description: 'DNS Seed',
      tooltip:
          'Query for peer addresses via DNS lookup, if low on addresses (default: 1 unless -connect used or -maxconnections=0)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'externalip',
      category: 'Connection',
      description: 'External IP',
      tooltip: 'Specify your own public address',
      inputType: ConfigInputType.ipAddress,
    ),

    // Wallet Options
    BitcoinConfigOption(
      key: 'addresstype',
      category: 'Wallet',
      description: 'Address Type',
      tooltip: 'What type of addresses to use ("legacy", "p2sh-segwit", "bech32", or "bech32m", default: "bech32")',
      inputType: ConfigInputType.dropdown,
      isUseful: true,
      defaultValue: 'bech32',
      dropdownValues: ['legacy', 'p2sh-segwit', 'bech32', 'bech32m'],
    ),
    BitcoinConfigOption(
      key: 'avoidpartialspends',
      category: 'Wallet',
      description: 'Avoid Partial Spends',
      tooltip:
          'Group outputs by address, selecting many (possibly all) or none, instead of selecting on a per-output basis. Privacy is improved as addresses are mostly swept with fewer transactions and outputs are aggregated in clean change addresses. Always enabled for wallets with "avoid_reuse" enabled, otherwise default: 0.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'changetype',
      category: 'Wallet',
      description: 'Change Address Type',
      tooltip:
          'What type of change to use ("legacy", "p2sh-segwit", "bech32", or "bech32m"). Default is "legacy" when -addresstype=legacy, else it is an implementation detail.',
      inputType: ConfigInputType.dropdown,
      dropdownValues: ['legacy', 'p2sh-segwit', 'bech32', 'bech32m'],
    ),
    BitcoinConfigOption(
      key: 'keypool',
      category: 'Wallet',
      description: 'Key Pool Size',
      tooltip:
          'Set key pool size to <n> (default: 1000). Warning: Smaller sizes may increase the risk of losing funds when restoring from an old backup, if none of the addresses in the original keypool have been used.',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
    ),
    BitcoinConfigOption(
      key: 'fallbackfee',
      category: 'Wallet',
      description: 'Fallback Fee Rate',
      tooltip:
          'A fee rate (in BTC/kvB) that will be used when fee estimation has insufficient data. 0 to entirely disable the fallbackfee feature. (default: 0.00)',
      inputType: ConfigInputType.bitcoinAmount,
      isUseful: true,
      defaultValue: 0.0,
      unit: 'BTC/kvB',
    ),
    BitcoinConfigOption(
      key: 'paytxfee',
      category: 'Wallet',
      description: 'Transaction Fee Rate',
      tooltip: 'Fee rate (in BTC/kvB) to add to transactions you send (default: 0.00)',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.0,
      unit: 'BTC/kvB',
    ),
    BitcoinConfigOption(
      key: 'mintxfee',
      category: 'Wallet',
      description: 'Minimum TX Fee',
      tooltip:
          'Fee rates (in BTC/kvB) smaller than this are considered zero fee for transaction creation (default: 0.00001)',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.00001,
      unit: 'BTC/kvB',
    ),
    BitcoinConfigOption(
      key: 'walletdir',
      category: 'Wallet',
      description: 'Wallet Directory',
      tooltip: 'Specify directory to hold wallets (default: <datadir>/wallets if it exists, otherwise <datadir>)',
      inputType: ConfigInputType.directory,
    ),
    BitcoinConfigOption(
      key: 'disablewallet',
      category: 'Wallet',
      description: 'Disable Wallet',
      tooltip: 'Do not load the wallet and disable wallet RPC calls',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),

    // ZeroMQ Options
    BitcoinConfigOption(
      key: 'zmqpubsequence',
      category: 'ZeroMQ',
      description: 'ZMQ Sequence',
      tooltip: 'Enable publish hash block and tx sequence in <address>',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'zmqpubhashblock',
      category: 'ZeroMQ',
      description: 'ZMQ Hash Block',
      tooltip: 'Enable publish hash block in <address>',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'zmqpubrawtx',
      category: 'ZeroMQ',
      description: 'ZMQ Raw Transaction',
      tooltip: 'Enable publish raw transaction in <address>',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'zmqpubrawblock',
      category: 'ZeroMQ',
      description: 'ZMQ Raw Block',
      tooltip: 'Enable publish raw block in <address>',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'zmqpubhashtx',
      category: 'ZeroMQ',
      description: 'ZMQ Hash Transaction',
      tooltip: 'Enable publish hash transaction in <address>',
      inputType: ConfigInputType.network,
    ),

    // RPC Server Options
    BitcoinConfigOption(
      key: 'server',
      category: 'RPC Server',
      description: 'RPC Server',
      tooltip: 'Accept command line and JSON-RPC commands',
      inputType: ConfigInputType.boolean,
      isUseful: true,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'rpcuser',
      category: 'RPC Server',
      description: 'RPC Username',
      tooltip: 'Username for JSON-RPC connections',
      inputType: ConfigInputType.text,
      isUseful: true,
    ),
    BitcoinConfigOption(
      key: 'rpcpassword',
      category: 'RPC Server',
      description: 'RPC Password',
      tooltip: 'Password for JSON-RPC connections',
      inputType: ConfigInputType.text,
      isUseful: true,
    ),
    BitcoinConfigOption(
      key: 'rpcport',
      category: 'RPC Server',
      description: 'RPC Port',
      tooltip:
          'Listen for JSON-RPC connections on <port> (default: 8332, testnet3: 18332, testnet4: 48332, signet: 38332, regtest: 18443)',
      inputType: ConfigInputType.number,
      isUseful: true,
      defaultValue: 8332,
      min: 1,
      max: 65535,
    ),
    BitcoinConfigOption(
      key: 'rpcbind',
      category: 'RPC Server',
      description: 'RPC Bind Address',
      tooltip:
          'Bind to given address to listen for JSON-RPC connections. Do not expose the RPC server to untrusted networks such as the public internet! This option is ignored unless -rpcallowip is also passed.',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'rpcallowip',
      category: 'RPC Server',
      description: 'RPC Allow IP',
      tooltip:
          'Allow JSON-RPC connections from specified source. Valid values for <ip> are a single IP (e.g. 1.2.3.4), a network/netmask (e.g. 1.2.3.4/255.255.255.0), a network/CIDR (e.g. 1.2.3.4/24), all ipv4 (0.0.0.0/0), or all ipv6 (::/0). This option can be specified multiple times',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'rest',
      category: 'RPC Server',
      description: 'REST API',
      tooltip: 'Accept public REST requests (default: 0)',
      inputType: ConfigInputType.boolean,
      isUseful: true,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'rpcthreads',
      category: 'RPC Server',
      description: 'RPC Threads',
      tooltip: 'Set the number of threads to service RPC calls (default: 16)',
      inputType: ConfigInputType.number,
      defaultValue: 16,
      min: 1,
    ),

    // Chain Selection Options
    BitcoinConfigOption(
      key: 'chain',
      category: 'Chain Selection',
      description: 'Blockchain Network',
      tooltip: 'Use the chain <chain> (default: main). Allowed values: main, test, testnet4, signet, regtest',
      inputType: ConfigInputType.dropdown,
      isUseful: true,
      defaultValue: 'main',
      dropdownValues: ['main', 'test', 'testnet4', 'signet', 'regtest'],
    ),
    BitcoinConfigOption(
      key: 'testnet',
      category: 'Chain Selection',
      description: 'Testnet3',
      tooltip:
          'Use the testnet3 chain. Equivalent to -chain=test. Support for testnet3 is deprecated and will be removed in an upcoming release. Consider moving to testnet4 now by using -testnet4.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'testnet4',
      category: 'Chain Selection',
      description: 'Testnet4',
      tooltip: 'Use the testnet4 chain. Equivalent to -chain=testnet4.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'signet',
      category: 'Chain Selection',
      description: 'Signet',
      tooltip:
          'Use the signet chain. Equivalent to -chain=signet. Note that the network is defined by the -signetchallenge parameter',
      inputType: ConfigInputType.boolean,
      isUseful: true,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'regtest',
      category: 'Chain Selection',
      description: 'Regtest',
      tooltip: 'Use the regtest chain. Equivalent to -chain=regtest.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'signetchallenge',
      category: 'Chain Selection',
      description: 'Signet Challenge',
      tooltip:
          'Blocks must satisfy the given script to be considered valid (only for signet networks; defaults to the global default signet test network challenge)',
      inputType: ConfigInputType.text,
    ),

    // Node Relay Options
    BitcoinConfigOption(
      key: 'minrelaytxfee',
      category: 'Node Relay',
      description: 'Min Relay TX Fee',
      tooltip:
          'Fees (in BTC/kvB) smaller than this are considered zero fee for relaying, mining and transaction creation (default: 0.000001)',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.000001,
      unit: 'BTC/kvB',
    ),
    BitcoinConfigOption(
      key: 'datacarrier',
      category: 'Node Relay',
      description: 'Data Carrier',
      tooltip: 'Relay and mine data carrier transactions (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'bytespersigop',
      category: 'Node Relay',
      description: 'Bytes Per Sigop',
      tooltip: 'Equivalent bytes per sigop in transactions for relay and mining (default: 20)',
      inputType: ConfigInputType.number,
      defaultValue: 20,
      min: 1,
    ),

    // Block Creation Options
    BitcoinConfigOption(
      key: 'blockmaxweight',
      category: 'Block Creation',
      description: 'Block Max Weight',
      tooltip: 'Set maximum BIP141 block weight (default: 4000000)',
      inputType: ConfigInputType.number,
      defaultValue: 4000000,
      min: 1,
    ),
    BitcoinConfigOption(
      key: 'blockmintxfee',
      category: 'Block Creation',
      description: 'Block Min TX Fee',
      tooltip:
          'Set lowest fee rate (in BTC/kvB) for transactions to be included in block creation. (default: 0.00000001)',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.00000001,
      unit: 'BTC/kvB',
    ),

    // More General Options
    BitcoinConfigOption(
      key: 'alertnotify',
      category: 'General',
      description: 'Alert Notify Command',
      tooltip: 'Execute command when an alert is raised (%s in cmd is replaced by message)',
      inputType: ConfigInputType.command,
    ),
    BitcoinConfigOption(
      key: 'blocknotify',
      category: 'General',
      description: 'Block Notify Command',
      tooltip: 'Execute command when the best block changes (%s in cmd is replaced by block hash)',
      inputType: ConfigInputType.command,
    ),
    BitcoinConfigOption(
      key: 'startupnotify',
      category: 'General',
      description: 'Startup Notify Command',
      tooltip: 'Execute command on startup.',
      inputType: ConfigInputType.command,
    ),
    BitcoinConfigOption(
      key: 'shutdownnotify',
      category: 'General',
      description: 'Shutdown Notify Command',
      tooltip:
          'Execute command immediately before beginning shutdown. The need for shutdown may be urgent, so be careful not to delay it long.',
      inputType: ConfigInputType.command,
    ),
    BitcoinConfigOption(
      key: 'reindex',
      category: 'General',
      description: 'Reindex Blockchain',
      tooltip:
          'If enabled, wipe chain state and block index, and rebuild them from blk*.dat files on disk. Also wipe and rebuild other optional indexes that are active.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'loadblock',
      category: 'General',
      description: 'Load Block File',
      tooltip: 'Imports blocks from external file on startup',
      inputType: ConfigInputType.file,
    ),
    BitcoinConfigOption(
      key: 'settings',
      category: 'General',
      description: 'Settings File',
      tooltip: 'Specify path to dynamic settings data file. Can be disabled with -nosettings. (default: settings.json)',
      inputType: ConfigInputType.file,
      defaultValue: 'settings.json',
    ),
    BitcoinConfigOption(
      key: 'includeconf',
      category: 'General',
      description: 'Include Config File',
      tooltip:
          'Specify additional configuration file, relative to the -datadir path (only useable from configuration file, not command line)',
      inputType: ConfigInputType.file,
    ),
    BitcoinConfigOption(
      key: 'allowignoredconf',
      category: 'General',
      description: 'Allow Ignored Config',
      tooltip:
          'For backwards compatibility, treat an unused bitcoin.conf file in the datadir as a warning, not an error.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'blockreconstructionextratxn',
      category: 'General',
      description: 'Block Reconstruction Extra Txn',
      tooltip: 'Extra transactions to keep in memory for compact block reconstructions (default: 100)',
      inputType: ConfigInputType.number,
      defaultValue: 100,
      min: 0,
    ),
    BitcoinConfigOption(
      key: 'blocksxor',
      category: 'General',
      description: 'Blocks XOR',
      tooltip:
          'Whether an XOR-key applies to blocksdir *.dat files. The created XOR-key will be zeros for an existing blocksdir or when `-blocksxor=0` is set, and random for a freshly initialized blocksdir. (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'daemonwait',
      category: 'General',
      description: 'Daemon Wait',
      tooltip: 'Wait for initialization to be finished before exiting. This implies -daemon (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'persistmempoolv1',
      category: 'General',
      description: 'Persist Mempool V1',
      tooltip:
          'Whether a mempool.dat file created by -persistmempool or the savemempool RPC will be written in the legacy format (version 1) or the current format (version 2). This temporary option will be removed in the future. (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'reindex-chainstate',
      category: 'General',
      description: 'Reindex Chainstate',
      tooltip:
          'If enabled, wipe chain state, and rebuild it from blk*.dat files on disk. If an assumeutxo snapshot was loaded, its chainstate will be wiped as well. The snapshot can then be reloaded via RPC.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'persistmempool',
      category: 'General',
      description: 'Persist Mempool',
      tooltip: 'Whether to save the mempool on shutdown and load on restart (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'mempoolexpiry',
      category: 'General',
      description: 'Mempool Expiry',
      tooltip: 'Do not keep transactions in the mempool longer than <n> hours (default: 336)',
      inputType: ConfigInputType.number,
      defaultValue: 336,
      min: 1,
      unit: 'hours',
    ),
    BitcoinConfigOption(
      key: 'maxorphantx',
      category: 'General',
      description: 'Max Orphan Transactions',
      tooltip: 'Keep at most <n> unconnectable transactions in memory (default: 100)',
      inputType: ConfigInputType.number,
      defaultValue: 100,
      min: 0,
    ),
    BitcoinConfigOption(
      key: 'blocksonly',
      category: 'General',
      description: 'Blocks Only',
      tooltip:
          'Whether to reject transactions from network peers. Disables automatic broadcast and rebroadcast of transactions, unless the source peer has the "forcerelay" permission. (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'coinstatsindex',
      category: 'General',
      description: 'Coin Stats Index',
      tooltip: 'Maintain coinstats index used by the gettxoutsetinfo RPC (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'blockfilterindex',
      category: 'General',
      description: 'Block Filter Index',
      tooltip:
          'Maintain an index of compact filters by block (default: 0, values: basic). If <type> is not supplied or if <type> = 1, indexes for all known types are enabled.',
      inputType: ConfigInputType.dropdown,
      dropdownValues: ['0', '1', 'basic'],
      defaultValue: '0',
    ),

    // More Connection Options
    BitcoinConfigOption(
      key: 'seednode',
      category: 'Connection',
      description: 'Seed Node',
      tooltip:
          'Connect to a node to retrieve peer addresses, and disconnect. This option can be specified multiple times to connect to multiple nodes.',
      inputType: ConfigInputType.ipAddress,
    ),
    BitcoinConfigOption(
      key: 'timeout',
      category: 'Connection',
      description: 'Connection Timeout',
      tooltip:
          'Specify socket connection timeout in milliseconds. If an initial attempt to connect is unsuccessful after this amount of time, drop it (minimum: 1, default: 5000)',
      inputType: ConfigInputType.number,
      defaultValue: 5000,
      min: 1,
      unit: 'ms',
    ),
    BitcoinConfigOption(
      key: 'maxreceivebuffer',
      category: 'Connection',
      description: 'Max Receive Buffer',
      tooltip: 'Maximum per-connection receive buffer, <n>*1000 bytes (default: 5000)',
      inputType: ConfigInputType.number,
      defaultValue: 5000,
      min: 1,
      unit: 'KB',
    ),
    BitcoinConfigOption(
      key: 'maxsendbuffer',
      category: 'Connection',
      description: 'Max Send Buffer',
      tooltip: 'Maximum per-connection memory usage for the send buffer, <n>*1000 bytes (default: 1000)',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
      unit: 'KB',
    ),
    BitcoinConfigOption(
      key: 'maxuploadtarget',
      category: 'Connection',
      description: 'Max Upload Target',
      tooltip:
          'Tries to keep outbound traffic under the given target per 24h. Limit does not apply to peers with "download" permission or blocks created within past week. 0 = no limit (default: 0M).',
      inputType: ConfigInputType.number,
      defaultValue: 0,
      min: 0,
      unit: 'MB',
    ),
    BitcoinConfigOption(
      key: 'bantime',
      category: 'Connection',
      description: 'Ban Time',
      tooltip: 'Default duration (in seconds) of manually configured bans (default: 86400)',
      inputType: ConfigInputType.number,
      defaultValue: 86400,
      min: 1,
      unit: 'seconds',
    ),
    BitcoinConfigOption(
      key: 'fixedseeds',
      category: 'Connection',
      description: 'Fixed Seeds',
      tooltip: 'Allow fixed seeds if DNS seeds do not provide peers (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'forcednsseed',
      category: 'Connection',
      description: 'Force DNS Seed',
      tooltip: 'Always query for peer addresses via DNS lookup (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'onlynet',
      category: 'Connection',
      description: 'Only Network',
      tooltip:
          'Make automatic outbound connections only to network <net> (ipv4, ipv6, onion, i2p, cjdns). Can be specified multiple times.',
      inputType: ConfigInputType.dropdown,
      dropdownValues: ['ipv4', 'ipv6', 'onion', 'i2p', 'cjdns'],
    ),
    BitcoinConfigOption(
      key: 'onion',
      category: 'Connection',
      description: 'Tor Proxy',
      tooltip:
          'Use separate SOCKS5 proxy to reach peers via Tor onion services, set -noonion to disable (default: -proxy). May be a local file path prefixed with "unix:".',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'listenonion',
      category: 'Connection',
      description: 'Listen on Onion',
      tooltip: 'Automatically create Tor onion service (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'torcontrol',
      category: 'Connection',
      description: 'Tor Control',
      tooltip:
          'Tor control host and port to use if onion listening enabled (default: 127.0.0.1:9051). If no port is specified, the default port of 9051 will be used.',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'torpassword',
      category: 'Connection',
      description: 'Tor Password',
      tooltip: 'Tor control port password (default: empty)',
      inputType: ConfigInputType.text,
    ),
    BitcoinConfigOption(
      key: 'i2psam',
      category: 'Connection',
      description: 'I2P SAM Proxy',
      tooltip: 'I2P SAM proxy to reach I2P peers and accept I2P connections (default: none)',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'networkactive',
      category: 'Connection',
      description: 'Network Active',
      tooltip: 'Enable all P2P network activity (default: 1). Can be changed by the setnetworkactive RPC command',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'whitelist',
      category: 'Connection',
      description: 'Whitelist',
      tooltip:
          'Add permission flags to the peers using the given IP address or CIDR-notated network. Uses the same permissions as -whitebind.',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'whitebind',
      category: 'Connection',
      description: 'White Bind',
      tooltip:
          'Bind to the given address and add permission flags to the peers connecting to it. Use [host]:port notation for IPv6.',
      inputType: ConfigInputType.network,
    ),
    BitcoinConfigOption(
      key: 'asmap',
      category: 'Connection',
      description: 'AS Map',
      tooltip:
          'Specify asn mapping used for bucketing of the peers (default: ip_asn.map). Relative paths will be prefixed by the net-specific datadir location.',
      inputType: ConfigInputType.file,
      defaultValue: 'ip_asn.map',
    ),
    BitcoinConfigOption(
      key: 'cjdnsreachable',
      category: 'Connection',
      description: 'CJDNS Reachable',
      tooltip:
          'If set, then this host is configured for CJDNS (connecting to fc00::/8 addresses would lead us to the CJDNS network, see doc/cjdns.md) (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'i2pacceptincoming',
      category: 'Connection',
      description: 'I2P Accept Incoming',
      tooltip:
          'Whether to accept inbound I2P connections (default: 1). Ignored if -i2psam is not set. Listening for inbound I2P connections is done through the SAM proxy, not by binding to a local address and port.',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'natpmp',
      category: 'Connection',
      description: 'NAT-PMP',
      tooltip: 'Use PCP or NAT-PMP to map the listening port (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'proxyrandomize',
      category: 'Connection',
      description: 'Proxy Randomize',
      tooltip: 'Randomize credentials for every proxy connection. This enables Tor stream isolation (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'v2transport',
      category: 'Connection',
      description: 'V2 Transport',
      tooltip: 'Support v2 transport (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),

    // More Wallet Options
    BitcoinConfigOption(
      key: 'wallet',
      category: 'Wallet',
      description: 'Wallet Path',
      tooltip:
          'Specify wallet path to load at startup. Can be used multiple times to load multiple wallets. Path is to a directory containing wallet data and log files.',
      inputType: ConfigInputType.file,
    ),
    BitcoinConfigOption(
      key: 'walletnotify',
      category: 'Wallet',
      description: 'Wallet Notify Command',
      tooltip:
          'Execute command when a wallet transaction changes. %s in cmd is replaced by TxID, %w is replaced by wallet name, %b is replaced by the hash of the block including the transaction.',
      inputType: ConfigInputType.command,
    ),
    BitcoinConfigOption(
      key: 'walletbroadcast',
      category: 'Wallet',
      description: 'Wallet Broadcast',
      tooltip: 'Make the wallet broadcast transactions (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'walletrbf',
      category: 'Wallet',
      description: 'Wallet RBF',
      tooltip: 'Send transactions with full-RBF opt-in enabled (RPC only, default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'spendzeroconfchange',
      category: 'Wallet',
      description: 'Spend Zero Conf Change',
      tooltip: 'Spend unconfirmed change when sending transactions (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'txconfirmtarget',
      category: 'Wallet',
      description: 'TX Confirm Target',
      tooltip:
          'If paytxfee is not set, include enough fee so transactions begin confirmation on average within n blocks (default: 6)',
      inputType: ConfigInputType.number,
      defaultValue: 6,
      min: 1,
      unit: 'blocks',
    ),
    BitcoinConfigOption(
      key: 'consolidatefeerate',
      category: 'Wallet',
      description: 'Consolidate Fee Rate',
      tooltip:
          "The maximum feerate (in BTC/kvB) at which transaction building may use more inputs than strictly necessary so that the wallet's UTXO pool can be reduced (default: 0.0001).",
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.0001,
      unit: 'BTC/kvB',
    ),
    BitcoinConfigOption(
      key: 'discardfee',
      category: 'Wallet',
      description: 'Discard Fee',
      tooltip:
          'The fee rate (in BTC/kvB) that indicates your tolerance for discarding change by adding it to the fee (default: 0.0001).',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.0001,
      unit: 'BTC/kvB',
    ),
    BitcoinConfigOption(
      key: 'maxapsfee',
      category: 'Wallet',
      description: 'Max APS Fee',
      tooltip:
          'Spend up to this amount in additional (absolute) fees (in BTC) if it allows the use of partial spend avoidance (default: 0.00)',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.0,
      unit: 'BTC',
    ),
    BitcoinConfigOption(
      key: 'signer',
      category: 'Wallet',
      description: 'External Signer',
      tooltip: 'External signing tool, see doc/external-signer.md',
      inputType: ConfigInputType.command,
    ),

    // More RPC Options
    BitcoinConfigOption(
      key: 'rpcauth',
      category: 'RPC Server',
      description: 'RPC Auth',
      tooltip:
          'Username and HMAC-SHA-256 hashed password for JSON-RPC connections. The field userpw comes in the format: USERNAME:SALT\$HASH.',
      inputType: ConfigInputType.text,
    ),
    BitcoinConfigOption(
      key: 'rpccookiefile',
      category: 'RPC Server',
      description: 'RPC Cookie File',
      tooltip:
          'Location of the auth cookie. Relative paths will be prefixed by a net-specific datadir location. (default: data dir)',
      inputType: ConfigInputType.file,
    ),
    BitcoinConfigOption(
      key: 'rpcwhitelist',
      category: 'RPC Server',
      description: 'RPC Whitelist',
      tooltip:
          'Set a whitelist to filter incoming RPC calls for a specific user. The field whitelist comes in the format: USERNAME:rpc1,rpc2,...,rpcN.',
      inputType: ConfigInputType.text,
    ),
    BitcoinConfigOption(
      key: 'rpccookieperms',
      category: 'RPC Server',
      description: 'RPC Cookie Permissions',
      tooltip:
          'Set permissions on the RPC auth cookie file so that it is readable by [owner|group|all] (default: owner [via umask 0077])',
      inputType: ConfigInputType.dropdown,
      defaultValue: 'owner',
      dropdownValues: ['owner', 'group', 'all'],
    ),
    BitcoinConfigOption(
      key: 'rpcwhitelistdefault',
      category: 'RPC Server',
      description: 'RPC Whitelist Default',
      tooltip:
          'Sets default behavior for rpc whitelisting. Unless rpcwhitelistdefault is set to 0, if any -rpcwhitelist is set, the rpc server acts as if all rpc users are subject to empty-unless-otherwise-specified whitelists. If rpcwhitelistdefault is set to 1 and no -rpcwhitelist is set, rpc server acts as if all rpc users are subject to empty whitelists.',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),

    // More ZeroMQ Options with HWM settings
    BitcoinConfigOption(
      key: 'zmqpubhashblockhwm',
      category: 'ZeroMQ',
      description: 'ZMQ Hash Block HWM',
      tooltip: 'Set publish hash block outbound message high water mark (default: 1000)',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
    ),
    BitcoinConfigOption(
      key: 'zmqpubhashtxhwm',
      category: 'ZeroMQ',
      description: 'ZMQ Hash TX HWM',
      tooltip: 'Set publish hash transaction outbound message high water mark (default: 1000)',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
    ),
    BitcoinConfigOption(
      key: 'zmqpubrawblockhwm',
      category: 'ZeroMQ',
      description: 'ZMQ Raw Block HWM',
      tooltip: 'Set publish raw block outbound message high water mark (default: 1000)',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
    ),
    BitcoinConfigOption(
      key: 'zmqpubrawtxhwm',
      category: 'ZeroMQ',
      description: 'ZMQ Raw TX HWM',
      tooltip: 'Set publish raw transaction outbound message high water mark (default: 1000)',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
    ),
    BitcoinConfigOption(
      key: 'zmqpubsequencehwm',
      category: 'ZeroMQ',
      description: 'ZMQ Sequence HWM',
      tooltip: 'Set publish hash sequence message high water mark (default: 1000)',
      inputType: ConfigInputType.number,
      defaultValue: 1000,
      min: 1,
    ),

    // More Chain Selection Options
    BitcoinConfigOption(
      key: 'signetblocktime',
      category: 'Chain Selection',
      description: 'Signet Block Time',
      tooltip:
          'Difficulty adjustment will target a block time of the given amount in seconds (only for custom signet networks, must have -signetchallenge set; defaults to 10 minutes)',
      inputType: ConfigInputType.number,
      defaultValue: 600,
      min: 1,
      unit: 'seconds',
    ),
    BitcoinConfigOption(
      key: 'signetseednode',
      category: 'Chain Selection',
      description: 'Signet Seed Node',
      tooltip:
          'Specify a seed node for the signet network, in the hostname[:port] format, e.g. sig.net:1234 (may be used multiple times)',
      inputType: ConfigInputType.ipAddress,
    ),

    // More Node Relay Options
    BitcoinConfigOption(
      key: 'datacarriersize',
      category: 'Node Relay',
      description: 'Data Carrier Size',
      tooltip:
          'Relay and mine transactions whose data-carrying raw scriptPubKey is of this size or less (default: 4000000)',
      inputType: ConfigInputType.number,
      defaultValue: 4000000,
      min: 1,
      unit: 'bytes',
    ),
    BitcoinConfigOption(
      key: 'permitbaremultisig',
      category: 'Node Relay',
      description: 'Permit Bare Multisig',
      tooltip: 'Relay transactions creating non-P2SH multisig outputs (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'whitelistforcerelay',
      category: 'Node Relay',
      description: 'Whitelist Force Relay',
      tooltip:
          'Add "forcerelay" permission to whitelisted peers with default permissions. This will relay transactions even if the transactions were already in the mempool. (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'whitelistrelay',
      category: 'Node Relay',
      description: 'Whitelist Relay',
      tooltip:
          'Add "relay" permission to whitelisted peers with default permissions. This will accept relayed transactions even when not relaying transactions (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'peerblockfilters',
      category: 'Node Relay',
      description: 'Peer Block Filters',
      tooltip: 'Serve compact block filters to peers per BIP 157 (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'peerbloomfilters',
      category: 'Node Relay',
      description: 'Peer Bloom Filters',
      tooltip: 'Support filtering of blocks and transaction with bloom filters (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),

    // More Block Creation Options
    BitcoinConfigOption(
      key: 'blockreservedweight',
      category: 'Block Creation',
      description: 'Block Reserved Weight',
      tooltip:
          'Reserve space for the fixed-size block header plus the largest coinbase transaction the mining software may add to the block. (default: 8000).',
      inputType: ConfigInputType.number,
      defaultValue: 8000,
      min: 0,
    ),

    // Debugging Options
    BitcoinConfigOption(
      key: 'debug',
      category: 'Debugging',
      description: 'Debug Categories',
      tooltip:
          'Output debug and trace logging. If not supplied or if 1 or "all", output all debug logging. Other valid values: addrman, bench, blockstorage, cmpctblock, coindb, estimatefee, http, i2p, ipc, leveldb, libevent, mempool, mempoolrej, net, proxy, prune, qt, rand, reindex, rpc, scan, selectcoins, tor, txpackages, txreconciliation, validation, walletdb, zmq.',
      inputType: ConfigInputType.text,
    ),
    BitcoinConfigOption(
      key: 'debugexclude',
      category: 'Debugging',
      description: 'Debug Exclude',
      tooltip:
          'Exclude debug and trace logging for a category. Can be used in conjunction with -debug=1 to output debug and trace logging for all categories except the specified category.',
      inputType: ConfigInputType.text,
    ),
    BitcoinConfigOption(
      key: 'printtoconsole',
      category: 'Debugging',
      description: 'Print To Console',
      tooltip:
          'Send trace/debug info to console (default: 1 when no -daemon. To disable logging to file, set -nodebuglogfile)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'logips',
      category: 'Debugging',
      description: 'Log IP Addresses',
      tooltip: 'Include IP addresses in debug output (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'logtimestamps',
      category: 'Debugging',
      description: 'Log Timestamps',
      tooltip: 'Prepend debug output with timestamp (default: 1)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'shrinkdebugfile',
      category: 'Debugging',
      description: 'Shrink Debug File',
      tooltip: 'Shrink debug.log file on client startup (default: 1 when no -debug)',
      inputType: ConfigInputType.boolean,
      defaultValue: true,
    ),
    BitcoinConfigOption(
      key: 'loglevelalways',
      category: 'Debugging',
      description: 'Log Level Always',
      tooltip: 'Always prepend a category and level (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'logsourcelocations',
      category: 'Debugging',
      description: 'Log Source Locations',
      tooltip:
          'Prepend debug output with name of the originating source location (source file, line number and function name) (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'logthreadnames',
      category: 'Debugging',
      description: 'Log Thread Names',
      tooltip: 'Prepend debug output with name of the originating thread (default: 0)',
      inputType: ConfigInputType.boolean,
      defaultValue: false,
    ),
    BitcoinConfigOption(
      key: 'debuglogfile',
      category: 'Debugging',
      description: 'Debug Log File',
      tooltip:
          'Specify location of debug log file (default: debug.log). Relative paths will be prefixed by a net-specific datadir location. Pass -nodebuglogfile to disable writing the log to a file.',
      inputType: ConfigInputType.file,
      defaultValue: 'debug.log',
    ),
    BitcoinConfigOption(
      key: 'maxtxfee',
      category: 'Debugging',
      description: 'Max TX Fee',
      tooltip:
          'Maximum total fees (in BTC) to use in a single wallet transaction; setting this too low may abort large transactions (default: 0.10)',
      inputType: ConfigInputType.bitcoinAmount,
      defaultValue: 0.10,
      unit: 'BTC',
    ),
    BitcoinConfigOption(
      key: 'uacomment',
      category: 'Debugging',
      description: 'User Agent Comment',
      tooltip: 'Append comment to the user agent string',
      inputType: ConfigInputType.text,
    ),
  ];

  static List<String> get categories {
    return allOptions.map((o) => o.category).toSet().toList()..sort();
  }

  static List<BitcoinConfigOption> getByCategory(String category) {
    return allOptions.where((o) => o.category == category).toList();
  }

  static List<BitcoinConfigOption> get usefulOptions {
    return allOptions.where((o) => o.isUseful).toList();
  }

  static BitcoinConfigOption? getByKey(String key) {
    try {
      return allOptions.firstWhere((o) => o.key == key);
    } catch (e) {
      return null;
    }
  }
}
