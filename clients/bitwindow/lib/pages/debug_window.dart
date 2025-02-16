import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
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
    return SailRawCard(
      withCloseButton: widget.newWindowIdentifier != null,
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
            child: ConsoleTab(),
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
    return SailRawCard(
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

class ConsoleTab extends StatefulWidget {
  const ConsoleTab({super.key});

  @override
  State<ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends State<ConsoleTab> {
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();

  late final List<String> _allCommands;
  String? _currentService;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<String> _commandHistory = [];
  int _historyIndex = -1;

  List<ConsoleEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    // Just merge all commands into one list
    _allCommands = [
      ...mainchain.getMethods(),
      ...bitwindow.getMethods(),
      ...enforcer.getMethods(),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _determineService(String command) {
    // Check if command exists in bitwindow methods
    if (bitwindow.getMethods().contains(command)) {
      return 'bitwindowd';
    }
    if (enforcer.getMethods().contains(command)) {
      return 'enforcer';
    }
    // Default to bitcoind
    return 'bitcoind';
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    String service;
    String command;
    List<String> args;

    // Remove any extra whitespace
    text = text.trim();

    // Simple split on first whitespace
    final firstSpace = text.indexOf(' ');
    if (firstSpace == -1) {
      command = text;
      args = [];
    } else {
      command = text.substring(0, firstSpace);
      if (text.contains('{')) {
        // its json! split on '} '
        args = text.substring(firstSpace + 1).split(' {').map((e) => e.trim()).toList();
      } else {
        args = text.substring(firstSpace + 1).split(' ').map((e) => e.trim()).toList();
      }
    }

    service = _determineService(command);
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    setState(() {
      entries.add(
        ConsoleEntry(
          timestamp: now,
          content: text,
          type: EntryType.command,
          requestId: requestId,
        ),
      );
      _commandHistory.add(text);
      _historyIndex = _commandHistory.length;
      _controller.clear();
      _currentService = service;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      dynamic response;
      switch (service) {
        case 'bitcoind':
          response = await mainchain.callRAW(command, args);
          break;
        case 'bitwindowd':
        // The enforcer does not actually have connect, but all protos are copied 1-1 in bitwindow
        // So we send RPCs to bitwindowd instead
        case 'enforcer':
          String jsonBody = '{}';
          if (args.isNotEmpty) {
            try {
              json.decode(args[0]).toString();
              jsonBody = args[0];
            } catch (e) {
              throw Exception('Arguments must be a single JSON object, e.g. {"key": "value"} $e');
            }
          }
          response = await bitwindow.callRAW(command, jsonBody);
          break;
        default:
          throw Exception('Unknown service: $service');
      }

      // Try to format response
      String formattedResponse;
      try {
        if (response is String) {
          // If it's a string, try to parse as JSON
          final jsonData = json.decode(response);
          formattedResponse = const JsonEncoder.withIndent('  ').convert(jsonData);
        } else {
          // If it's already a Map/List, just encode it
          formattedResponse = const JsonEncoder.withIndent('  ').convert(response);
        }
      } catch (e) {
        // Not JSON, use raw response
        formattedResponse = response.toString();
      }

      _addResponse(
        ConsoleEntry(
          timestamp: DateTime.now(),
          content: formattedResponse,
          type: EntryType.response,
          requestId: requestId,
        ),
      );
    } catch (e) {
      _addResponse(
        ConsoleEntry(
          timestamp: DateTime.now(),
          content: 'Error: ${e.toString()}',
          type: EntryType.error,
          requestId: requestId,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_historyIndex > 0) {
        _historyIndex--;
        _controller.text = _commandHistory[_historyIndex];
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIndex < _commandHistory.length - 1) {
        _historyIndex++;
        _controller.text = _commandHistory[_historyIndex];
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      } else {
        _historyIndex = _commandHistory.length;
        _controller.clear();
      }
    }
  }

  bool hasResponse(String requestId) {
    return entries.any(
      (e) => e.requestId == requestId && (e.type == EntryType.response || e.type == EntryType.error),
    );
  }

  void _addResponse(ConsoleEntry responseEntry) {
    setState(() {
      // Find the index of the matching request
      final requestIndex = entries.indexWhere(
        (e) => e.requestId == responseEntry.requestId && e.type == EntryType.command,
      );

      if (requestIndex != -1) {
        // Insert response right after its request
        entries.insert(requestIndex + 1, responseEntry);
      } else {
        // Fallback: add to end if request not found
        entries.add(responseEntry);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailRawCard(
      title: 'Debug Console',
      subtitle: 'Execute commands and view responses',
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: theme.colors.backgroundSecondary,
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ConsoleEntryWidget(entry: entry, entries: entries);
                },
              ),
            ),
          ),
          Container(
            color: theme.colors.backgroundSecondary,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Command input (now includes the RPC selector)
                Expanded(
                  child: KeyboardListener(
                    focusNode: _focusNode,
                    onKeyEvent: _handleKeyPress,
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        final searchTerm = textEditingValue.text.toLowerCase();
                        return _allCommands.where((command) {
                          final service = _determineService(command);
                          // Search in both service and command
                          return command.toLowerCase().contains(searchTerm) ||
                              service.toLowerCase().contains(searchTerm);
                        });
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            color: theme.colors.background,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final command = options.elementAt(index);
                                  final service = _determineService(command);
                                  return InkWell(
                                    onTap: () => onSelected(command),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: SailText.primary12(
                                        '$service -> $command',
                                        color: theme.colors.text,
                                        monospace: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _currentService = _determineService(selection);
                          _controller.text = selection;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: selection.length),
                          );
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: TextStyle(
                            color: theme.colors.text,
                            fontFamily: 'SourceCodePro',
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(left: 8),
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_currentService != null) // Only show if we have a service
                                    SailText.primary13(
                                      _currentService!,
                                      color: theme.colors.textTertiary,
                                      monospace: true,
                                    ),
                                  if (_currentService != null) const SizedBox(width: 8),
                                  SailText.primary13(
                                    '>',
                                    color: theme.colors.text,
                                    monospace: true,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            fillColor: theme.colors.background,
                            filled: true,
                          ),
                          onSubmitted: _handleSubmitted,
                          onChanged: (value) {
                            if (_currentService != null) {
                              setState(() {
                                _currentService = null;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum EntryType { command, response, error }

class ConsoleEntry {
  final DateTime timestamp;
  final String content;
  final EntryType type;
  final String requestId;

  bool get isGrouped => requestId != '';
  bool get isGroupStart => type == EntryType.command;

  ConsoleEntry({
    required this.timestamp,
    required this.content,
    required this.type,
    required this.requestId,
  });
}

class ConsoleEntryWidget extends StatelessWidget {
  final ConsoleEntry entry;
  final List<ConsoleEntry> entries;
  final _timeFormat = DateFormat('HH:mm:ss');

  ConsoleEntryWidget({super.key, required this.entry, required this.entries});

  bool _hasResponse(String requestId) => entries.any(
        (e) => e.requestId == requestId && (e.type == EntryType.response || e.type == EntryType.error),
      );

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    Color getColor() {
      switch (entry.type) {
        case EntryType.command:
          return theme.colors.primary;
        case EntryType.response:
          return theme.colors.text;
        case EntryType.error:
          return theme.colors.error;
      }
    }

    return Container(
      decoration: entry.isGrouped
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            )
          : null,
      margin: EdgeInsets.only(
        left: entry.isGrouped ? 16 : 0,
        top: entry.isGroupStart ? 16 : 0,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SailSpacing(SailStyleValues.padding08),
          SailText.secondary13(
            _timeFormat.format(entry.timestamp),
            color: theme.colors.textTertiary,
            monospace: true,
          ),
          const SizedBox(width: 8),
          if (entry.type == EntryType.command) ...[
            if (!_hasResponse(entry.requestId))
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: theme.colors.primary,
                ),
              )
            else
              const Icon(Icons.chevron_right, size: 16),
          ] else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              entry.content,
              style: TextStyle(
                color: getColor(),
                fontFamily: 'SourceCodePro',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SailRawCard(
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

    return SailRawCard(
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
        child: SailRawCard(
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
