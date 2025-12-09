import 'package:bitwindow/pages/bitwindow_console_tab.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class DebugWindow extends StatefulWidget {
  const DebugWindow({
    super.key,
  });

  @override
  State<DebugWindow> createState() => _DebugWindowState();
}

class _DebugWindowState extends State<DebugWindow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      color: context.sailTheme.colors.background,
      inSeparateWindow: true,
      child: InlineTabBar(
        tabs: const [
          TabItem(
            label: 'Information',
            icon: SailSVGAsset.iconInfo,
            child: InformationTab(),
          ),
          TabItem(
            label: 'Processes',
            icon: SailSVGAsset.iconTools,
            child: ProcessesTab(),
          ),
          TabItem(
            label: 'Console',
            icon: SailSVGAsset.iconTerminal,
            child: BitwindowConsoleTab(),
          ),
          TabItem(
            label: 'Network',
            icon: SailSVGAsset.iconNetwork,
            child: NetworkTab(),
          ),
          TabItem(
            label: 'Peers',
            icon: SailSVGAsset.iconPeers,
            child: PeersTab(),
          ),
        ],
        initialIndex: 0,
      ),
    );
  }
}

class InformationTab extends StatefulWidget {
  const InformationTab({super.key});

  @override
  State<InformationTab> createState() => _InformationTabState();
}

class _InformationTabState extends State<InformationTab> {
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();

  BlockchainInfo? _blockchainInfo;
  NetworkInfo? _networkInfo;
  MempoolInfo? _mempoolInfo;
  String? _dataDir;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final blockchainInfo = await mainchain.getBlockchainInfo();
      final networkInfo = await mainchain.getNetworkInfo();
      final mempoolInfo = await mainchain.getMempoolInfo();
      final dataDir = await mainchain.getDataDir();

      setState(() {
        _blockchainInfo = blockchainInfo;
        _networkInfo = networkInfo;
        _mempoolInfo = mempoolInfo;
        _dataDir = dataDir;
      });
    } catch (e) {
      // do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Debug Information',
      subtitle: 'General information about the node',
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding25,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoSection(
              title: 'General Info',
              details: {
                'Client version': _networkInfo?.version.toString() ?? 'Loading...',
                'User Agent': _networkInfo?.subversion ?? 'Loading...',
                'Protocol Version': _networkInfo?.protocolVersion.toString() ?? 'Loading...',
                'Datadir': _dataDir ?? 'Loading...',
              },
            ),
            InfoSection(
              title: 'Network Info',
              details: {
                'Chain': _blockchainInfo?.chain ?? 'Loading...',
                'Network Activity': _blockchainInfo?.initialBlockDownload ?? true ? 'Disabled' : 'Enabled',
              },
            ),
            InfoSection(
              title: 'Blockchain Info',
              details: {
                'Current number of blocks': _blockchainInfo?.blocks.toString() ?? 'Loading...',
                'Headers': _blockchainInfo?.headers.toString() ?? 'Loading...',
                'Verification Progress': '${((_blockchainInfo?.verificationProgress ?? 0) * 100).toStringAsFixed(0)}%',
                'Difficulty': _blockchainInfo?.difficulty.toString() ?? 'Loading...',
                'Size on Disk': '${_blockchainInfo?.sizeOnDisk ?? 0} bytes',
                'Last block time': _blockchainInfo?.time != null
                    ? DateTime.fromMillisecondsSinceEpoch(_blockchainInfo!.time * 1000).toString()
                    : 'Loading...',
              },
            ),
            InfoSection(
              title: 'Mempool Info',
              details: {
                'Transaction Count': _mempoolInfo?.size.toString() ?? 'Loading...',
                'Memory Usage': '${_mempoolInfo?.usage ?? 0} bytes',
                'Total Fee': '${_mempoolInfo?.totalFee ?? 0} BTC',
                'Min Relay Fee': '${_mempoolInfo?.minRelayTxFee ?? 0} BTC',
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final Map<String, String> details;

  const InfoSection({super.key, required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary15(title),
        const SizedBox(height: 8),
        ...details.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: SailText.secondary13(
                    e.key,
                  ),
                ),
                Expanded(
                  child: SailText.primary13(
                    e.value,
                    monospace: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NetworkTab extends StatefulWidget {
  const NetworkTab({super.key});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<NetworkTab> {
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();
  GetNetworkStatsResponse? _networkStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNetworkStats();
  }

  Future<void> _loadNetworkStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await bitwindow.bitwindowd.getNetworkStats();
      setState(() {
        _networkStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SailCard(
        title: 'Network Statistics',
        subtitle: 'Bitcoin network and node statistics',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_networkStats == null) {
      return SailCard(
        title: 'Network Statistics',
        subtitle: 'Bitcoin network and node statistics',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.secondary13('Failed to load network statistics'),
              const SizedBox(height: 16),
              SailButton(
                label: 'Retry',
                onPressed: () async => _loadNetworkStats(),
              ),
            ],
          ),
        ),
      );
    }

    return SailCard(
      title: 'Network Statistics',
      subtitle: 'Bitcoin network and node statistics',
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding25,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Refresh',
                  onPressed: () async => _loadNetworkStats(),
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),
            InfoSection(
              title: 'Connection Status',
              details: {
                'Connected Peers': _networkStats!.peerCount.toString(),
                'Inbound Connections': _networkStats!.connectionsIn.toString(),
                'Outbound Connections': _networkStats!.connectionsOut.toString(),
              },
            ),
            InfoSection(
              title: 'Block Information',
              details: {
                'Current Height': _networkStats!.blockHeight.toString(),
                'Average Block Time': '${_networkStats!.avgBlockTime.toStringAsFixed(1)}s',
                'Difficulty': _networkStats!.difficulty.toStringAsFixed(2),
              },
            ),
            InfoSection(
              title: 'Network Activity',
              details: {
                'Total Bytes Received': '${_networkStats!.totalBytesReceived} bytes',
                'Total Bytes Sent': '${_networkStats!.totalBytesSent} bytes',
                'Network Version': _networkStats!.networkVersion.toString(),
              },
            ),
            if (_networkStats!.hasBitcoindBandwidth())
              InfoSection(
                title: 'Bitcoind Process (PID ${_networkStats!.bitcoindBandwidth.pid})',
                details: {
                  'RX Rate': '${(_networkStats!.bitcoindBandwidth.rxBytesPerSec / 1024).toStringAsFixed(2)} KB/s',
                  'TX Rate': '${(_networkStats!.bitcoindBandwidth.txBytesPerSec / 1024).toStringAsFixed(2)} KB/s',
                  'Total RX':
                      '${(_networkStats!.bitcoindBandwidth.totalRxBytes.toInt() / 1024 / 1024).toStringAsFixed(2)} MB',
                  'Total TX':
                      '${(_networkStats!.bitcoindBandwidth.totalTxBytes.toInt() / 1024 / 1024).toStringAsFixed(2)} MB',
                  'Connections': _networkStats!.bitcoindBandwidth.connectionCount.toString(),
                },
              ),
            if (_networkStats!.hasEnforcerBandwidth())
              InfoSection(
                title: 'Enforcer Process (PID ${_networkStats!.enforcerBandwidth.pid})',
                details: {
                  'RX Rate': '${(_networkStats!.enforcerBandwidth.rxBytesPerSec / 1024).toStringAsFixed(2)} KB/s',
                  'TX Rate': '${(_networkStats!.enforcerBandwidth.txBytesPerSec / 1024).toStringAsFixed(2)} KB/s',
                  'Total RX':
                      '${(_networkStats!.enforcerBandwidth.totalRxBytes.toInt() / 1024 / 1024).toStringAsFixed(2)} MB',
                  'Total TX':
                      '${(_networkStats!.enforcerBandwidth.totalTxBytes.toInt() / 1024 / 1024).toStringAsFixed(2)} MB',
                  'Connections': _networkStats!.enforcerBandwidth.connectionCount.toString(),
                },
              ),
          ],
        ),
      ),
    );
  }
}

class PeersTab extends StatefulWidget {
  const PeersTab({super.key});

  @override
  State<PeersTab> createState() => _PeersTabState();
}

class _PeersTabState extends State<PeersTab> {
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  List<PeerInfo> peers = [];

  @override
  void initState() {
    super.initState();
    _loadPeers();
  }

  Future<void> _loadPeers() async {
    final peerList = await mainchain.getPeerInfo();
    setState(() {
      peers = peerList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailCard(
      title: 'Peer Information',
      subtitle: 'Connected peers and their details',
      child: SailTable(
        backgroundColor: theme.colors.backgroundSecondary,
        getRowId: (index) => index.toString(),
        headerBuilder: (context) => [
          const SailTableHeaderCell(name: 'ID'),
          const SailTableHeaderCell(name: 'Address'),
          const SailTableHeaderCell(name: 'Network'),
          const SailTableHeaderCell(name: 'Version'),
          const SailTableHeaderCell(name: 'Connection'),
          const SailTableHeaderCell(name: 'Ping'),
        ],
        rowBuilder: (context, row, selected) {
          final peer = peers[row];
          return [
            SailTableCell(value: peer.id.toString()),
            SailTableCell(value: peer.addr),
            SailTableCell(value: peer.network),
            SailTableCell(value: peer.subVer),
            SailTableCell(value: peer.connectionType),
            SailTableCell(value: '${peer.pingTime.toStringAsFixed(3)}s'),
          ];
        },
        rowCount: peers.length,
        emptyPlaceholder: 'No peers connected',
        onDoubleTap: (index) {
          showDialog(
            context: context,
            builder: (context) => PeerDetailsDialog(peer: peers[int.parse(index)]),
          );
        },
      ),
    );
  }
}

class PeerDetailsDialog extends StatelessWidget {
  final PeerInfo peer;

  const PeerDetailsDialog({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Dialog(
      backgroundColor: theme.colors.background,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SailCard(
          title: 'Peer Details',
          subtitle: 'Full details about the peer',
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                DetailSection(
                  title: 'Connection',
                  details: {
                    'ID': peer.id.toString(),
                    'Address': peer.addr,
                    'Bind Address': peer.addrBind,
                    'Local Address': peer.addrLocal,
                    'Network': peer.network,
                    'Connection Type': peer.connectionType,
                    'Transport Protocol': peer.transportProtocolType,
                    'Session ID': peer.sessionId,
                  },
                ),
                const SizedBox(height: 16),
                DetailSection(
                  title: 'Status',
                  details: {
                    'Version': peer.version.toString(),
                    'Subversion': peer.subVer,
                    'Services': peer.services,
                    'Service Names': peer.serviceNames.join(', '),
                    'Inbound': peer.inbound.toString(),
                    'Relay Transactions': peer.relayTxes.toString(),
                    'Time Offset': '${peer.timeOffset}s',
                    'Ping Time': '${peer.pingTime}s',
                    'Min Ping': '${peer.minPing}s',
                  },
                ),
                const SizedBox(height: 16),
                DetailSection(
                  title: 'Sync Status',
                  details: {
                    'Starting Height': peer.startingHeight.toString(),
                    'Synced Headers': peer.syncedHeaders.toString(),
                    'Synced Blocks': peer.syncedBlocks.toString(),
                    'Last Transaction': peer.lastTransaction == 0
                        ? 'Never'
                        : DateTime.fromMillisecondsSinceEpoch(peer.lastTransaction * 1000).toString(),
                    'Last Block': peer.lastBlock == 0
                        ? 'Never'
                        : DateTime.fromMillisecondsSinceEpoch(peer.lastBlock * 1000).toString(),
                  },
                ),
                const SizedBox(height: 16),
                DetailSection(
                  title: 'Traffic',
                  details: {
                    'Bytes Sent': '${peer.bytesSent} bytes',
                    'Bytes Received': '${peer.bytesRecv} bytes',
                    'Last Send': peer.lastSend == 0
                        ? 'Never'
                        : DateTime.fromMillisecondsSinceEpoch(peer.lastSend * 1000).toString(),
                    'Last Receive': peer.lastRecv == 0
                        ? 'Never'
                        : DateTime.fromMillisecondsSinceEpoch(peer.lastRecv * 1000).toString(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailSection extends StatelessWidget {
  final String title;
  final Map<String, String> details;

  const DetailSection({super.key, required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary15(title),
        const SizedBox(height: 8),
        ...details.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: SailText.secondary13(
                    '${e.key}:',
                    color: SailTheme.of(context).colors.textTertiary,
                  ),
                ),
                Expanded(
                  child: SailText.primary13(
                    e.value,
                    monospace: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProcessesTab extends StatelessWidget {
  const ProcessesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final theme = context.sailTheme;

    return ListenableBuilder(
      listenable: binaryProvider,
      builder: (context, _) {
        final processes = binaryProvider.runningBinaries;

        return SailCard(
          title: 'Running Processes',
          subtitle: 'Processes managed by this application',
          child: SailTable(
            backgroundColor: theme.colors.backgroundSecondary,
            getRowId: (index) => processes[index].name,
            headerBuilder: (context) => [
              const SailTableHeaderCell(name: 'Name'),
              const SailTableHeaderCell(name: 'PID'),
              const SailTableHeaderCell(name: 'Type'),
              const SailTableHeaderCell(name: 'Port'),
              const SailTableHeaderCell(name: 'Adopted'),
            ],
            rowBuilder: (context, row, selected) {
              final binary = processes[row];
              final pid = binaryProvider.getPidForBinary(binary);
              final adopted = binaryProvider.isAdopted(binary);

              return [
                SailTableCell(value: binary.name),
                SailTableCell(value: pid?.toString() ?? '-'),
                SailTableCell(value: binary.type.name),
                SailTableCell(value: binary.port.toString()),
                SailTableCell(value: adopted ? 'Yes' : 'No'),
              ];
            },
            rowCount: processes.length,
            emptyPlaceholder: 'No processes running',
          ),
        );
      },
    );
  }
}
