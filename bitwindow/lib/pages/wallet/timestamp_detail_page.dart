import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class TimestampDetailViewModel extends BaseViewModel {
  final TimestampProvider _timestampProvider = GetIt.I.get<TimestampProvider>();
  final int timestampId;

  FileTimestamp? timestamp;
  bool isLoading = false;
  @override
  String? modelError;

  TimestampDetailViewModel(this.timestampId) {
    _loadTimestamp();
    _timestampProvider.addListener(_onTimestampProviderChanged);
  }

  void _onTimestampProviderChanged() {
    _loadTimestamp();
  }

  Future<void> _loadTimestamp() async {
    isLoading = true;
    notifyListeners();

    timestamp = _timestampProvider.timestamps.cast<FileTimestamp?>().firstWhere(
      (t) => t?.id.toInt() == timestampId,
      orElse: () => null,
    );

    if (timestamp == null) {
      modelError = 'Timestamp not found';
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timestampProvider.removeListener(_onTimestampProviderChanged);
    super.dispose();
  }

  void copyHash(BuildContext context) {
    if (timestamp != null) {
      Clipboard.setData(ClipboardData(text: timestamp!.fileHash));
      showSnackBar(context, 'Hash copied to clipboard');
    }
  }

  void copyTxid(BuildContext context) {
    if (timestamp != null && timestamp!.hasTxid()) {
      Clipboard.setData(ClipboardData(text: timestamp!.txid));
      showSnackBar(context, 'Transaction ID copied to clipboard');
    }
  }
}

@RoutePage()
class TimestampDetailPage extends StatelessWidget {
  final int timestampId;

  const TimestampDetailPage({super.key, required this.timestampId});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Timestamp Details',
      body: ViewModelBuilder<TimestampDetailViewModel>.reactive(
        viewModelBuilder: () => TimestampDetailViewModel(timestampId),
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (model.timestamp == null) {
            return Center(
              child: SailText.primary15(model.modelError ?? 'Timestamp not found'),
            );
          }

          final ts = model.timestamp!;

          return Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding32),
            child: SailColumn(
              mainAxisSize: MainAxisSize.min,
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: 'Filename', value: ts.filename),
                CopyRow(
                  label: 'File Hash',
                  value: ts.fileHash,
                  onCopy: () => model.copyHash(context),
                ),
                InfoRow(
                  label: 'Created',
                  value: _formatDate(ts.createdAt),
                ),
                StatusRow(status: ts.status),
                if (ts.hasTxid())
                  CopyRow(
                    label: 'Transaction ID',
                    value: ts.txid,
                    onCopy: () => model.copyTxid(context),
                  ),
                if (ts.hasBlockHeight())
                  InfoRow(
                    label: 'Block Height',
                    value: ts.blockHeight.toString(),
                  ),
                if (ts.hasConfirmedAt())
                  InfoRow(
                    label: 'Confirmed',
                    value: _formatDate(ts.confirmedAt),
                  ),
                const SizedBox(height: SailStyleValues.padding16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Close',
                      onPressed: () async => GetIt.I.get<AppRouter>().pop(),
                    ),
                  ],
                ),
              ],
            ),
          );
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
      return DateFormat('MMM d, yyyy HH:mm:ss').format(dt);
    } catch (e) {
      return '-';
    }
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13(label),
        ),
        const SizedBox(width: SailStyleValues.padding12),
        Flexible(
          child: SailText.primary13(value),
        ),
      ],
    );
  }
}

class CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const CopyRow({
    super.key,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13(label),
        ),
        const SizedBox(width: SailStyleValues.padding12),
        Flexible(
          child: SailText.primary13(
            value.length > 50 ? '${value.substring(0, 50)}...' : value,
          ),
        ),
        const SizedBox(width: SailStyleValues.padding12),
        IconButton(
          icon: SailSVG.icon(SailSVGAsset.iconCopy),
          onPressed: onCopy,
          iconSize: 16,
        ),
      ],
    );
  }
}

class StatusRow extends StatelessWidget {
  final String status;

  const StatusRow({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13('Status'),
        ),
        const SizedBox(width: SailStyleValues.padding12),
        Flexible(
          child: SailText.primary13(status.toUpperCase()),
        ),
      ],
    );
  }
}
