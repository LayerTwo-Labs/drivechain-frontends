import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/console/integrated_console_view.dart';

/// A comprehensive debug window for sidechain applications.
/// Provides tabs for Information, Processes, Console, and Peers.
class SidechainDebugWindow extends StatelessWidget {
  final SidechainRPC rpc;
  final String sidechainName;

  const SidechainDebugWindow({
    super.key,
    required this.rpc,
    required this.sidechainName,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      color: context.sailTheme.colors.background,
      inSeparateWindow: true,
      child: InlineTabBar(
        tabs: [
          TabItem(
            label: 'Information',
            icon: SailSVGAsset.iconInfo,
            child: SidechainInfoTab(rpc: rpc, sidechainName: sidechainName),
          ),
          TabItem(
            label: 'Processes',
            icon: SailSVGAsset.iconTools,
            child: SidechainProcessesTab(),
          ),
          TabItem(
            label: 'Console',
            icon: SailSVGAsset.iconTerminal,
            child: SidechainConsoleTab(sidechainName: sidechainName),
          ),
          TabItem(
            label: 'Peers',
            icon: SailSVGAsset.iconPeers,
            child: SidechainPeersTab(rpc: rpc),
          ),
          TabItem(
            label: 'RPC Methods',
            icon: SailSVGAsset.iconNetwork,
            child: SidechainRPCMethodsTab(rpc: rpc),
          ),
        ],
        initialIndex: 0,
      ),
    );
  }
}

/// Information tab showing sidechain blockchain info, balance, and wealth.
class SidechainInfoTab extends StatefulWidget {
  final SidechainRPC rpc;
  final String sidechainName;

  const SidechainInfoTab({
    super.key,
    required this.rpc,
    required this.sidechainName,
  });

  @override
  State<SidechainInfoTab> createState() => _SidechainInfoTabState();
}

class _SidechainInfoTabState extends State<SidechainInfoTab> {
  BlockchainInfo? _blockchainInfo;
  double? _confirmedBalance;
  double? _unconfirmedBalance;
  double? _sidechainWealth;
  bool _isLoading = true;
  String? _error;
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
      if (_autoRefreshEnabled) {
        _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (mounted) _loadInfo();
        });
      } else {
        _autoRefreshTimer?.cancel();
        _autoRefreshTimer = null;
      }
    });
  }

  Future<void> _loadInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final blockchainInfo = await widget.rpc.getBlockchainInfo();
      final (confirmed, unconfirmed) = await widget.rpc.balance();

      // Try to get sidechain wealth - may not be available on all sidechains
      double? wealth;
      try {
        wealth = await _getSidechainWealth();
      } catch (e) {
        // Sidechain wealth not available
      }

      if (mounted) {
        setState(() {
          _blockchainInfo = blockchainInfo;
          _confirmedBalance = confirmed;
          _unconfirmedBalance = unconfirmed;
          _sidechainWealth = wealth;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<double?> _getSidechainWealth() async {
    // Different sidechains have different methods for getting wealth
    try {
      final result = await widget.rpc.callRAW('sidechain_wealth_sats');
      if (result is int) {
        return satoshiToBTC(result);
      }
    } catch (e) {
      // Try alternative method name
      try {
        final result = await widget.rpc.callRAW('sidechain_wealth');
        if (result is int) {
          return satoshiToBTC(result);
        }
      } catch (e) {
        // Not available
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SailCard(
        title: 'Debug Information',
        subtitle: 'General information about the sidechain node',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SailCard(
        title: 'Debug Information',
        subtitle: 'General information about the sidechain node',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.secondary13('Failed to load information'),
              const SizedBox(height: 8),
              SailText.secondary12(_error!, color: context.sailTheme.colors.error),
              const SizedBox(height: 16),
              SailButton(
                label: 'Retry',
                onPressed: () async => _loadInfo(),
              ),
            ],
          ),
        ),
      );
    }

    return SailCard(
      title: 'Debug Information',
      subtitle: 'General information about the ${widget.sidechainName} node',
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding25,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailText.secondary12('Auto-refresh'),
                    SailToggle(
                      value: _autoRefreshEnabled,
                      onChanged: (_) => _toggleAutoRefresh(),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                SailButton(
                  label: 'Refresh',
                  onPressed: () async => _loadInfo(),
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),
            SidechainInfoSection(
              title: 'General Info',
              details: {
                'Sidechain': widget.sidechainName,
                'Network': _blockchainInfo?.chain ?? 'Unknown',
                'Connected': widget.rpc.connected ? 'Yes' : 'No',
              },
            ),
            SidechainInfoSection(
              title: 'Blockchain Info',
              details: {
                'Current Block Height': _blockchainInfo?.blocks.toString() ?? 'Loading...',
                'Headers': _blockchainInfo?.headers.toString() ?? 'Loading...',
                'Best Block Hash': _truncateHash(_blockchainInfo?.bestBlockHash ?? ''),
                'Sync Progress': '${((_blockchainInfo?.verificationProgress ?? 0) * 100).toStringAsFixed(0)}%',
              },
            ),
            SidechainInfoSection(
              title: 'Wallet Info',
              details: {
                'Confirmed Balance': '${_confirmedBalance?.toStringAsFixed(8) ?? '0.00000000'} BTC',
                'Unconfirmed Balance': '${_unconfirmedBalance?.toStringAsFixed(8) ?? '0.00000000'} BTC',
                'Total Balance': '${((_confirmedBalance ?? 0) + (_unconfirmedBalance ?? 0)).toStringAsFixed(8)} BTC',
                if (_sidechainWealth != null) 'Total Sidechain Wealth': '${_sidechainWealth!.toStringAsFixed(8)} BTC',
              },
            ),
          ],
        ),
      ),
    );
  }

  String _truncateHash(String hash) {
    if (hash.length <= 20) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 10)}';
  }
}

/// Section widget for displaying grouped information.
class SidechainInfoSection extends StatelessWidget {
  final String title;
  final Map<String, String> details;

  const SidechainInfoSection({
    super.key,
    required this.title,
    required this.details,
  });

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
                  width: 200,
                  child: SailText.secondary13(e.key),
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

/// Processes tab showing running binaries managed by the application.
class SidechainProcessesTab extends StatelessWidget {
  const SidechainProcessesTab({super.key});

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
              const SailTableHeaderCell(name: 'Status'),
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
                SailTableCell(value: adopted ? 'Adopted' : 'Managed'),
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

/// Console tab wrapping the integrated console view.
class SidechainConsoleTab extends StatelessWidget {
  final String sidechainName;

  const SidechainConsoleTab({
    super.key,
    required this.sidechainName,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Debug Console',
      subtitle: 'Execute $sidechainName CLI commands',
      child: const IntegratedConsoleView(),
    );
  }
}

/// Peers tab showing connected peers.
class SidechainPeersTab extends StatefulWidget {
  final SidechainRPC rpc;

  const SidechainPeersTab({
    super.key,
    required this.rpc,
  });

  @override
  State<SidechainPeersTab> createState() => _SidechainPeersTabState();
}

class _SidechainPeersTabState extends State<SidechainPeersTab> {
  List<SidechainPeerInfo> _peers = [];
  bool _isLoading = true;
  String? _error;
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPeers();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
      if (_autoRefreshEnabled) {
        _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (mounted) _loadPeers();
        });
      } else {
        _autoRefreshTimer?.cancel();
        _autoRefreshTimer = null;
      }
    });
  }

  Future<void> _connectPeer(String address) async {
    try {
      await widget.rpc.callRAW('connect_peer', [address]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connecting to $address...')),
        );
        await _loadPeers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  void _showConnectPeerDialog() {
    showDialog(
      context: context,
      builder: (context) => ConnectPeerDialog(
        onConnect: _connectPeer,
      ),
    );
  }

  Future<void> _loadPeers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final peersRaw = await widget.rpc.callRAW('list_peers');
      final peers = <SidechainPeerInfo>[];

      if (peersRaw is List) {
        for (final peer in peersRaw) {
          if (peer is Map<String, dynamic>) {
            peers.add(SidechainPeerInfo.fromJson(peer));
          }
        }
      }

      if (mounted) {
        setState(() {
          _peers = peers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    if (_isLoading) {
      return const SailCard(
        title: 'Peer Information',
        subtitle: 'Connected peers and their details',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SailCard(
        title: 'Peer Information',
        subtitle: 'Connected peers and their details',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SailText.secondary13('Failed to load peers'),
              const SizedBox(height: 8),
              SailText.secondary12(_error!, color: theme.colors.error),
              const SizedBox(height: 16),
              SailButton(
                label: 'Retry',
                onPressed: () async => _loadPeers(),
              ),
            ],
          ),
        ),
      );
    }

    return SailCard(
      title: 'Peer Information',
      subtitle: 'Connected peers and their details',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailText.secondary13('${_peers.length} peer(s) connected'),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailText.secondary12('Auto-refresh'),
                      SailToggle(
                        value: _autoRefreshEnabled,
                        onChanged: (_) => _toggleAutoRefresh(),
                      ),
                    ],
                  ),
                  SailButton(
                    label: 'Connect Peer',
                    onPressed: () async => _showConnectPeerDialog(),
                    variant: ButtonVariant.secondary,
                  ),
                  SailButton(
                    label: 'Refresh',
                    onPressed: () async => _loadPeers(),
                    variant: ButtonVariant.secondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SailTable(
              backgroundColor: theme.colors.backgroundSecondary,
              getRowId: (index) => _peers[index].address,
              headerBuilder: (context) => [
                const SailTableHeaderCell(name: 'Address'),
                const SailTableHeaderCell(name: 'Status'),
              ],
              rowBuilder: (context, row, selected) {
                final peer = _peers[row];
                return [
                  SailTableCell(value: peer.address),
                  SailTableCell(value: peer.status),
                ];
              },
              rowCount: _peers.length,
              emptyPlaceholder: 'No peers connected',
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic peer info class that works across all sidechains.
class SidechainPeerInfo {
  final String address;
  final String status;

  SidechainPeerInfo({
    required this.address,
    required this.status,
  });

  factory SidechainPeerInfo.fromJson(Map<String, dynamic> json) {
    return SidechainPeerInfo(
      address: json['address'] as String? ?? json['addr'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? json['state'] as String? ?? 'Connected',
    );
  }
}

/// Dialog for connecting to a new peer.
class ConnectPeerDialog extends StatefulWidget {
  final Future<void> Function(String address) onConnect;

  const ConnectPeerDialog({
    super.key,
    required this.onConnect,
  });

  @override
  State<ConnectPeerDialog> createState() => _ConnectPeerDialogState();
}

class _ConnectPeerDialogState extends State<ConnectPeerDialog> {
  final _addressController = TextEditingController();
  bool _isConnecting = false;
  String? _error;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() => _error = 'Please enter a peer address');
      return;
    }

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      await widget.onConnect(address);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Dialog(
      backgroundColor: theme.colors.background,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15('Connect to Peer'),
            const SizedBox(height: 8),
            SailText.secondary13('Enter the address of the peer you want to connect to.'),
            const SizedBox(height: 16),
            SailTextField(
              controller: _addressController,
              hintText: 'e.g., 127.0.0.1:8080 or peer.example.com:8080',
              enabled: !_isConnecting,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              SailText.secondary12(_error!, color: theme.colors.error),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SailButton(
                  label: 'Cancel',
                  onPressed: () async => Navigator.of(context).pop(),
                  variant: ButtonVariant.secondary,
                  disabled: _isConnecting,
                ),
                const SizedBox(width: 8),
                SailButton(
                  label: _isConnecting ? 'Connecting...' : 'Connect',
                  onPressed: _connect,
                  disabled: _isConnecting,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// RPC Methods tab showing available RPC methods for the sidechain.
class SidechainRPCMethodsTab extends StatefulWidget {
  final SidechainRPC rpc;

  const SidechainRPCMethodsTab({
    super.key,
    required this.rpc,
  });

  @override
  State<SidechainRPCMethodsTab> createState() => _SidechainRPCMethodsTabState();
}

class _SidechainRPCMethodsTabState extends State<SidechainRPCMethodsTab> {
  List<String> _methods = [];
  List<String> _filteredMethods = [];
  final _searchController = TextEditingController();
  String? _selectedMethod;
  String? _methodResult;
  bool _isExecuting = false;
  final _paramsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMethods();
    _searchController.addListener(_filterMethods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _paramsController.dispose();
    super.dispose();
  }

  void _loadMethods() {
    final methods = widget.rpc.getMethods();
    setState(() {
      _methods = methods..sort();
      _filteredMethods = _methods;
    });
  }

  void _filterMethods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMethods = _methods;
      } else {
        _filteredMethods = _methods.where((m) => m.toLowerCase().contains(query)).toList();
      }
    });
  }

  Future<void> _executeMethod() async {
    if (_selectedMethod == null) return;

    setState(() {
      _isExecuting = true;
      _methodResult = null;
    });

    try {
      List<dynamic>? params;
      final paramsText = _paramsController.text.trim();
      if (paramsText.isNotEmpty) {
        // If it looks like JSON array, try to parse it
        if (paramsText.startsWith('[')) {
          try {
            final parsed = _parseJsonArray(paramsText);
            params = parsed;
          } catch (e) {
            // Use as single string param
            params = [paramsText];
          }
        } else {
          // Single parameter - wrap in list
          params = [paramsText];
        }
      }

      final result = await widget.rpc.callRAW(_selectedMethod!, params);
      if (mounted) {
        setState(() {
          _methodResult = _formatResult(result);
          _isExecuting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _methodResult = 'Error: $e';
          _isExecuting = false;
        });
      }
    }
  }

  List<dynamic> _parseJsonArray(String text) {
    // Simple JSON array parser
    final result = <dynamic>[];
    var depth = 0;
    var inString = false;
    var escape = false;
    var currentItem = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final char = text[i];

      if (escape) {
        currentItem.write(char);
        escape = false;
        continue;
      }

      if (char == '\\' && inString) {
        currentItem.write(char);
        escape = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        currentItem.write(char);
        continue;
      }

      if (inString) {
        currentItem.write(char);
        continue;
      }

      if (char == '[') {
        if (depth > 0) currentItem.write(char);
        depth++;
        continue;
      }

      if (char == ']') {
        depth--;
        if (depth == 0) {
          final item = currentItem.toString().trim();
          if (item.isNotEmpty) {
            result.add(_parseValue(item));
          }
        } else {
          currentItem.write(char);
        }
        continue;
      }

      if (char == ',' && depth == 1) {
        final item = currentItem.toString().trim();
        if (item.isNotEmpty) {
          result.add(_parseValue(item));
        }
        currentItem = StringBuffer();
        continue;
      }

      if (depth > 0) {
        currentItem.write(char);
      }
    }

    return result;
  }

  dynamic _parseValue(String value) {
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(value);
    if (asDouble != null) return asDouble;
    return value;
  }

  String _formatResult(dynamic result) {
    if (result == null) return 'null';
    if (result is Map || result is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(result);
      } catch (e) {
        return result.toString();
      }
    }
    return result.toString();
  }

  void _copyResult() {
    if (_methodResult != null) {
      Clipboard.setData(ClipboardData(text: _methodResult!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SailCard(
      title: 'RPC Methods',
      subtitle: 'Browse and execute available RPC methods',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Methods list
          SizedBox(
            width: 250,
            child: Column(
              children: [
                SailTextField(
                  controller: _searchController,
                  hintText: 'Search methods...',
                  prefixIcon: Icon(
                    Icons.search,
                    size: 16,
                    color: theme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.backgroundSecondary,
                      borderRadius: SailStyleValues.borderRadius,
                    ),
                    child: ListView.builder(
                      itemCount: _filteredMethods.length,
                      itemBuilder: (context, index) {
                        final method = _filteredMethods[index];
                        final isSelected = method == _selectedMethod;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMethod = method;
                              _methodResult = null;
                              _paramsController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            color: isSelected ? theme.colors.primary.withValues(alpha: 0.1) : null,
                            child: SailText.primary13(
                              method,
                              monospace: true,
                              color: isSelected ? theme.colors.primary : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SailText.secondary12('${_filteredMethods.length} methods'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Method details and execution
          Expanded(
            child: _selectedMethod == null
                ? Center(
                    child: SailText.secondary13('Select a method to view details'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary15(_selectedMethod!),
                      const SizedBox(height: 16),
                      SailText.secondary13('Parameters (optional):'),
                      const SizedBox(height: 8),
                      SailTextField(
                        controller: _paramsController,
                        hintText: 'Enter parameters (JSON or string)',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      SailButton(
                        label: _isExecuting ? 'Executing...' : 'Execute',
                        onPressed: _executeMethod,
                        disabled: _isExecuting,
                      ),
                      const SizedBox(height: 16),
                      if (_methodResult != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SailText.secondary13('Result:'),
                            SailButton(
                              label: 'Copy',
                              onPressed: () async => _copyResult(),
                              variant: ButtonVariant.secondary,
                              small: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colors.backgroundSecondary,
                              borderRadius: SailStyleValues.borderRadius,
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _methodResult!,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: _methodResult!.startsWith('Error:') ? theme.colors.error : theme.colors.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// JSON encoder for formatting results.
class JsonEncoder {
  final String? indent;

  const JsonEncoder.withIndent(this.indent);

  String convert(dynamic object) {
    return _encode(object, 0);
  }

  String _encode(dynamic object, int depth) {
    final indentStr = indent ?? '';
    final currentIndent = indentStr * depth;
    final nextIndent = indentStr * (depth + 1);

    if (object == null) return 'null';
    if (object is bool) return object.toString();
    if (object is num) return object.toString();
    if (object is String) return '"${_escapeString(object)}"';

    if (object is List) {
      if (object.isEmpty) return '[]';
      final items = object.map((e) => '$nextIndent${_encode(e, depth + 1)}').join(',\n');
      return '[\n$items\n$currentIndent]';
    }

    if (object is Map) {
      if (object.isEmpty) return '{}';
      final entries = object.entries.map((e) => '$nextIndent"${e.key}": ${_encode(e.value, depth + 1)}').join(',\n');
      return '{\n$entries\n$currentIndent}';
    }

    return object.toString();
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
