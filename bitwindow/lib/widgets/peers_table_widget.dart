import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class PeersTableViewModel extends BaseViewModel {
  final BlockchainProvider _blockchainProvider = GetIt.I.get<BlockchainProvider>();

  String sortColumn = 'addr';
  bool sortAscending = true;

  PeersTableViewModel() {
    _blockchainProvider.addListener(notifyListeners);
  }

  List<Peer> get peers => _blockchainProvider.peers;

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    notifyListeners();
  }

  List<Peer> get sortedPeers {
    final sorted = List<Peer>.from(peers);
    sorted.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'addr':
          aValue = a.addr;
          bValue = b.addr;
          break;
        case 'direction':
          aValue = a.inbound ? 0 : 1;
          bValue = b.inbound ? 0 : 1;
          break;
        case 'ping':
          aValue = a.pingTime;
          bValue = b.pingTime;
          break;
        case 'sent':
          aValue = a.bytesSent;
          bValue = b.bytesSent;
          break;
        case 'recv':
          aValue = a.bytesReceived;
          bValue = b.bytesReceived;
          break;
        case 'conntime':
          aValue = a.connectedAt.seconds;
          bValue = b.connectedAt.seconds;
          break;
        default:
          aValue = a.addr;
          bValue = b.addr;
      }

      final comparison = (aValue as Comparable).compareTo(bValue);
      return sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  @override
  void dispose() {
    _blockchainProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class PeersTableWidget extends StatelessWidget {
  const PeersTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PeersTableViewModel>.reactive(
      viewModelBuilder: () => PeersTableViewModel(),
      builder: (context, model, child) {
        return SailCard(
          title: 'Connected Peers',
          subtitle: '${model.peers.length} peer${model.peers.length == 1 ? '' : 's'} connected',
          child: model.peers.isEmpty
              ? const PeersTablePlaceholder()
              : SizedBox(
                  height: 300,
                  child: PeersTable(
                    peers: model.sortedPeers,
                    sortColumn: model.sortColumn,
                    sortAscending: model.sortAscending,
                    onSort: model.onSort,
                  ),
                ),
        );
      },
    );
  }
}

class PeersTablePlaceholder extends StatelessWidget {
  const PeersTablePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SailColumn(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SailSVG.icon(
              SailSVGAsset.iconPeers,
              width: 32,
              color: context.sailTheme.colors.textTertiary,
            ),
            SailText.secondary13('No peers connected'),
          ],
        ),
      ),
    );
  }
}

class PeersTable extends StatelessWidget {
  final List<Peer> peers;
  final String sortColumn;
  final bool sortAscending;
  final Function(String) onSort;

  const PeersTable({
    super.key,
    required this.peers,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ['addr', 'direction', 'ping', 'sent', 'recv', 'conntime'];

    return SailTable(
      getRowId: (index) => peers[index].addr,
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Address', onSort: () => onSort('addr')),
        SailTableHeaderCell(name: 'Direction', onSort: () => onSort('direction')),
        SailTableHeaderCell(name: 'Ping', onSort: () => onSort('ping')),
        SailTableHeaderCell(name: 'Sent', onSort: () => onSort('sent')),
        SailTableHeaderCell(name: 'Received', onSort: () => onSort('recv')),
        SailTableHeaderCell(name: 'Connected', onSort: () => onSort('conntime')),
      ],
      rowBuilder: (context, row, selected) {
        final peer = peers[row];
        return [
          SailTableCell(value: peer.addr),
          SailTableCell(value: peer.inbound ? 'Inbound' : 'Outbound'),
          SailTableCell(value: _formatPing(peer.pingTime)),
          SailTableCell(value: _formatBytes(peer.bytesSent.toInt())),
          SailTableCell(value: _formatBytes(peer.bytesReceived.toInt())),
          SailTableCell(value: _formatDuration(peer.connectedAt)),
        ];
      },
      rowCount: peers.length,
      drawGrid: true,
      sortColumnIndex: columns.indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(columns[columnIndex]);
      },
    );
  }

  String _formatPing(dynamic pingTime) {
    if (pingTime == null) return '-';
    try {
      // pingTime is a protobuf Duration with seconds and nanos
      final seconds = pingTime.seconds.toDouble();
      final nanos = pingTime.nanos.toDouble();
      final totalMs = (seconds * 1000) + (nanos / 1000000);

      if (totalMs <= 0) return '-';
      if (totalMs < 1) return '${(totalMs * 1000).toStringAsFixed(0)} \u00B5s';
      if (totalMs < 1000) return '${totalMs.toStringAsFixed(0)} ms';
      return '${(totalMs / 1000).toStringAsFixed(2)} s';
    } catch (e) {
      return '-';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDuration(dynamic connectedAt) {
    if (connectedAt == null) return '-';
    try {
      final int seconds = connectedAt.seconds.toInt();
      final connectedTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      final duration = DateTime.now().difference(connectedTime);

      if (duration.inDays > 0) {
        return '${duration.inDays}d ${duration.inHours % 24}h';
      } else if (duration.inHours > 0) {
        return '${duration.inHours}h ${duration.inMinutes % 60}m';
      } else if (duration.inMinutes > 0) {
        return '${duration.inMinutes}m';
      } else {
        return '${duration.inSeconds}s';
      }
    } catch (e) {
      return '-';
    }
  }
}
