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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SailCard(
                title: 'Timestamp Information',
                child: Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(context, 'Filename', ts.filename),
                      _buildCopyRow(
                        context,
                        'File Hash',
                        ts.fileHash,
                        () => model.copyHash(context),
                      ),
                      _buildInfoRow(
                        context,
                        'Created',
                        _formatDate(ts.createdAt),
                      ),
                      _buildStatusRow(context, ts.status),
                      if (ts.hasTxid())
                        _buildCopyRow(
                          context,
                          'Transaction ID',
                          ts.txid,
                          () => model.copyTxid(context),
                        ),
                      if (ts.hasBlockHeight())
                        _buildInfoRow(
                          context,
                          'Block Height',
                          ts.blockHeight.toString(),
                        ),
                      if (ts.hasConfirmedAt())
                        _buildInfoRow(
                          context,
                          'Confirmed',
                          _formatDate(ts.confirmedAt),
                        ),
                      const SizedBox(height: SailStyleValues.padding20),
                      SailButton(
                        label: 'Close',
                        onPressed: () async => GetIt.I.get<AppRouter>().pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13(label),
        ),
        Expanded(
          child: SailText.primary13(value),
        ),
      ],
    );
  }

  Widget _buildCopyRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback onCopy,
  ) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13(label),
        ),
        Expanded(
          child: SailText.primary13(
            value.length > 50 ? '${value.substring(0, 50)}...' : value,
          ),
        ),
        IconButton(
          icon: SailSVG.icon(SailSVGAsset.iconCopy),
          onPressed: onCopy,
          iconSize: 16,
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, String status) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        SizedBox(
          width: 150,
          child: SailText.secondary13('Status'),
        ),
        Expanded(
          child: SailText.primary13(status.toUpperCase()),
        ),
      ],
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
