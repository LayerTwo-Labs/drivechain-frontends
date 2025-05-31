import 'package:bitwindow/pages/bitwindow_console_tab.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class DebugWindow extends StatefulWidget {
  final NewWindowIdentifier? newWindowIdentifier;

  const DebugWindow({
    super.key,
    required this.newWindowIdentifier,
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
      inSeparateWindow: widget.newWindowIdentifier == null,
      newWindowIdentifier: widget.newWindowIdentifier,
      child: InlineTabBar(
        tabs: const [
          TabItem(
            label: 'Information',
            icon: SailSVGAsset.iconInfo,
            child: InformationTab(),
          ),
          TabItem(
            label: 'Console',
            icon: SailSVGAsset.iconTerminal,
            child: BitwindowConsoleTab(),
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

class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SailCard(
      title: 'Network Traffic',
      subtitle: 'View network traffic and statistics',
      child: Center(child: Text('Network tab content coming soon')),
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
        columnWidths: const [50, 200, 100, 200, 150, 100],
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
