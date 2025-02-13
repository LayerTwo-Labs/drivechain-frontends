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
import 'package:stacked/stacked.dart';

@RoutePage()
class DebugWindow extends StatelessWidget {
  const DebugWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailPadding(
      padding: EdgeInsets.only(
        top: SailStyleValues.padding16,
        left: SailStyleValues.padding16,
        right: SailStyleValues.padding16,
        bottom: SailStyleValues.padding64 * 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: Dialog(
          backgroundColor: theme.colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              ViewModelBuilder<DebugViewModel>.reactive(
                viewModelBuilder: () => DebugViewModel(),
                builder: (context, model, child) {
                  return InlineTabBar(
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
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: SailScaleButton(
                  child: SailSVG.fromAsset(
                    SailSVGAsset.iconClose,
                    width: 15,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DebugViewModel extends BaseViewModel {
  // Add debug-related functionality here
}

class InformationTab extends StatelessWidget {
  const InformationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SailRawCard(
      title: 'Debug Information',
      subtitle: 'General information about the node',
      child: Center(child: Text('Information tab content coming soon')),
    );
  }
}

class ConsoleTab extends StatefulWidget {
  const ConsoleTab({super.key});

  @override
  State<ConsoleTab> createState() => _ConsoleTabState();
}

// Add enum for RPC types
enum RPCType {
  bitcoind,
  enforcer,
  bitwindow,
}

class _ConsoleTabState extends State<ConsoleTab> {
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  BitwindowRPC get bitwindow => GetIt.I.get<BitwindowRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();

  RPCType _currentRPC = RPCType.bitcoind;
  late final Map<RPCType, List<String>> _allCommands;

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

    // Initialize commands
    _allCommands = {
      RPCType.bitcoind: mainchain.getMethods(),
      RPCType.bitwindow: bitwindow.getMethods(),
      RPCType.enforcer: enforcer.getMethods(),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    final now = DateTime.now();

    setState(() {
      entries.add(
        ConsoleEntry(
          timestamp: now,
          content: text,
          type: EntryType.command,
          isGroupStart: true, // Start a new group
          isGrouped: true,
        ),
      );
      _commandHistory.add(text);
      _historyIndex = _commandHistory.length;
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      final parts = text.split(' ');
      final command = parts[0];
      final args = parts.sublist(1);

      dynamic response;
      switch (_currentRPC) {
        case RPCType.bitcoind:
          final rawResponse = await mainchain.callRAW(command, args);
          // Bitcoin Core responses are already in JSON format
          response = const JsonEncoder.withIndent('  ').convert(rawResponse);
          break;
        case RPCType.enforcer:
          // For these RPCs, we need a single JSON object
          final jsonBody = args.isEmpty ? '{}' : args[0];
          if (args.length > 1 || (args.isNotEmpty && !jsonBody.startsWith('{'))) {
            throw Exception('Arguments must be a single JSON object, e.g. {"key": "value"}');
          }
          response = await enforcer.callRAW(command, jsonBody);
          break;
        case RPCType.bitwindow:
          // For these RPCs, we need a single JSON object
          // For these RPCs, we need a single JSON object
          final jsonBody = args.isEmpty ? '{}' : args[0];
          if (args.length > 1 || (args.isNotEmpty && !jsonBody.startsWith('{'))) {
            throw Exception('Arguments must be a single JSON object, e.g. {"key": "value"}');
          }
          response = await bitwindow.callRAW(command, jsonBody);
          break;
      }

      // Try to parse and pretty print JSON
      String formattedResponse;
      try {
        final jsonData = json.decode(response.toString());
        formattedResponse = const JsonEncoder.withIndent('  ').convert(jsonData);
      } catch (e) {
        // Not valid JSON, use raw response
        formattedResponse = response.toString();
      }

      setState(() {
        entries.add(
          ConsoleEntry(
            timestamp: DateTime.now(),
            content: formattedResponse,
            type: EntryType.response,
            isGrouped: true,
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        entries.add(
          ConsoleEntry(
            timestamp: DateTime.now(),
            content: 'Error: ${e.toString()}',
            type: EntryType.error,
            isGrouped: true, // Part of the same group
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

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
                  return ConsoleEntryWidget(entry: entry);
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
                  child: RawKeyboardListener(
                    focusNode: _focusNode,
                    onKey: _handleKeyPress,
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _commands.where((command) {
                          // Search for the term anywhere in the command
                          return command.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            color: theme.colors.background,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: SailText.primary12(
                                        option,
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
                        _controller.text = selection;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: selection.length),
                        );
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
                                  SailDropdownButton<RPCType>(
                                    value: _currentRPC,
                                    items: RPCType.values
                                        .map(
                                          (type) => SailDropdownItem(
                                            value: type,
                                            child: SailText.primary12(
                                              type.name,
                                              monospace: true,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (type) {
                                      if (type != null) {
                                        setState(() => _currentRPC = type);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
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

  // Get commands for current RPC type
  List<String> get _commands => _allCommands[_currentRPC] ?? [];
}

enum EntryType { command, response, error }

class ConsoleEntry {
  final DateTime timestamp;
  final String content;
  final EntryType type;
  final bool isGrouped; // Whether this entry is part of a group
  final bool isGroupStart; // Whether this entry starts a new group

  ConsoleEntry({
    required this.timestamp,
    required this.content,
    required this.type,
    this.isGrouped = false,
    this.isGroupStart = false,
  });
}

class ConsoleEntryWidget extends StatelessWidget {
  final ConsoleEntry entry;
  final _timeFormat = DateFormat('HH:mm:ss');

  ConsoleEntryWidget({super.key, required this.entry});

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
                  color: theme.colors.primary.withOpacity(0.3),
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
          if (entry.type == EntryType.command) const Icon(Icons.chevron_right, size: 16) else const SizedBox(width: 16),
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
                _buildDetailSection(
                  context,
                  'Connection',
                  {
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
                _buildDetailSection(
                  context,
                  'Status',
                  {
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
                _buildDetailSection(
                  context,
                  'Sync Status',
                  {
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
                _buildDetailSection(
                  context,
                  'Traffic',
                  {
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

  Widget _buildDetailSection(BuildContext context, String title, Map<String, String> details) {
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
