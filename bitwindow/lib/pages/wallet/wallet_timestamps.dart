import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class TimestampsTabViewModel extends BaseViewModel {
  final TimestampProvider _timestampProvider = GetIt.I.get<TimestampProvider>();

  List<FileTimestamp> get timestamps => _timestampProvider.timestamps;
  bool get isLoading => _timestampProvider.isLoading;
  @override
  String? get modelError => _timestampProvider.modelError;

  TimestampsTabViewModel() {
    _timestampProvider.addListener(_onTimestampProviderChanged);
  }

  void _onTimestampProviderChanged() {
    notifyListeners();
  }

  Future<void> refresh() async {
    await _timestampProvider.fetch();
  }

  void timestampFile(BuildContext context) {
    GetIt.I.get<AppRouter>().push(const CreateTimestampRoute());
  }

  void verifyFile(BuildContext context) {
    GetIt.I.get<AppRouter>().push(const VerifyTimestampRoute());
  }

  @override
  void dispose() {
    _timestampProvider.removeListener(_onTimestampProviderChanged);
    super.dispose();
  }
}

class TimestampsTab extends StatelessWidget {
  const TimestampsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TimestampsTabViewModel>.reactive(
      viewModelBuilder: () => TimestampsTabViewModel(),
      onViewModelReady: (model) => model.refresh(),
      builder: (context, model, child) {
        return SailCard(
          title: 'File Timestamps',
          error: model.modelError,
          bottomPadding: false,
          widgetHeaderEnd: model.timestamps.isNotEmpty
              ? SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    SailButton(
                      label: 'Verify File',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => model.verifyFile(context),
                    ),
                    SailButton(
                      label: 'Timestamp New File',
                      onPressed: () async => model.timestampFile(context),
                    ),
                  ],
                )
              : null,
          child: model.timestamps.isEmpty
              ? Center(
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailText.primary15('No timestamps yet'),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SailButton(
                            label: 'Verify a File',
                            variant: ButtonVariant.secondary,
                            onPressed: () async => model.verifyFile(context),
                          ),
                          SailButton(
                            label: 'Timestamp Your First File',
                            onPressed: () async => model.timestampFile(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : TimestampsTable(timestamps: model.timestamps),
        );
      },
    );
  }
}

class TimestampsTable extends StatelessWidget {
  final List<FileTimestamp> timestamps;

  const TimestampsTable({
    super.key,
    required this.timestamps,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SailTable(
        drawGrid: true,
        getRowId: (index) => timestamps[index].id.toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(name: 'Filename'),
          SailTableHeaderCell(name: 'Hash'),
          SailTableHeaderCell(name: 'Timestamped'),
          SailTableHeaderCell(name: 'Status'),
          SailTableHeaderCell(name: 'Block Height'),
          SailTableHeaderCell(name: 'Actions'),
        ],
        rowBuilder: (context, row, selected) {
          final timestamp = timestamps[row];
          return [
            SailTableCell(value: timestamp.filename),
            SailTableCell(
              value: _truncateHash(timestamp.fileHash),
              copyValue: timestamp.fileHash,
            ),
            SailTableCell(value: _formatDate(timestamp.confirmedAt)),
            SailTableCell(
              value: _getStatusLabel(timestamp.status, timestamp.confirmations),
              textColor: _getStatusColor(context, timestamp.status),
            ),
            SailTableCell(
              value: timestamp.hasBlockHeight() ? timestamp.blockHeight.toString() : '-',
            ),
            SailTableCell(
              value: 'View Details',
              child: SailButton(
                label: 'View Details',
                onPressed: () async => _viewTimestamp(context, timestamp),
                variant: ButtonVariant.secondary,
                insideTable: true,
              ),
            ),
          ];
        },
        rowCount: timestamps.length,
        onDoubleTap: (rowId) {
          final timestamp = timestamps.firstWhere((t) => t.id.toString() == rowId);
          _viewTimestamp(context, timestamp);
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        timestamp.seconds * 1000 + timestamp.nanos ~/ 1000000,
      );
      return DateFormat('MMM d, yyyy HH:mm').format(dt);
    } catch (e) {
      return '-';
    }
  }

  String _truncateHash(String hash) {
    if (hash.length <= 20) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 10)}';
  }

  String _getStatusLabel(String status, int confirmations) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirming':
        return confirmations > 0 ? 'Confirming ($confirmations)' : 'Confirming (0)';
      case 'confirmed':
        return confirmations > 0 ? 'Confirmed ($confirmations)' : 'Confirmed';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = context.sailTheme.colors;
    switch (status) {
      case 'pending':
        return theme.orange;
      case 'confirming':
        return theme.primary;
      case 'confirmed':
        return theme.success;
      case 'failed':
        return theme.error;
      default:
        return theme.text;
    }
  }

  void _viewTimestamp(BuildContext context, FileTimestamp timestamp) {
    GetIt.I.get<AppRouter>().push(TimestampDetailRoute(timestampId: timestamp.id.toInt()));
  }
}
