import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

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
      showSailToast(context, 'Hash copied to clipboard');
    }
  }

  void copyTxid(BuildContext context) {
    if (timestamp != null && timestamp!.hasTxid()) {
      Clipboard.setData(ClipboardData(text: timestamp!.txid));
      showSailToast(context, 'Transaction ID copied to clipboard');
    }
  }
}

@RoutePage()
class TimestampDetailPage extends StatelessWidget {
  final int timestampId;

  const TimestampDetailPage({super.key, required this.timestampId});

  @override
  Widget build(BuildContext context) {
    if (SailStyleValues.phoneLayout(context)) {
      return SailScaffold(
        backgroundColor: SailTheme.of(context).colors.background,
        appBar: SailAppBar.build(context),
        body: ViewModelBuilder<TimestampDetailViewModel>.reactive(
          viewModelBuilder: () => TimestampDetailViewModel(timestampId),
          builder: (context, model, child) => _PhoneTimestampDetails(model: model),
        ),
      );
    }
    return SailPage(
      title: 'Timestamp Details',
      body: ViewModelBuilder<TimestampDetailViewModel>.reactive(
        viewModelBuilder: () => TimestampDetailViewModel(timestampId),
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Center(child: LoadingIndicator());
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
                  label: 'Timestamped',
                  value: formatConfirmedAt(ts, 'MMM d, yyyy HH:mm:ss'),
                ),
                StatusRow(status: ts.status),
                if (ts.status == 'confirming' || ts.status == 'confirmed')
                  InfoRow(
                    label: 'Confirmations',
                    value: ts.confirmations.toString(),
                  ),
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
}

class _PhoneTimestampDetails extends StatelessWidget {
  final TimestampDetailViewModel model;

  const _PhoneTimestampDetails({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    final ts = model.timestamp;
    if (ts == null) {
      return Center(child: SailText.primary15(model.modelError ?? 'Timestamp not found'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        child: SailCard(
          title: 'Timestamp Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SailColumn(
                spacing: 0,
                withDivider: true,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailValueRow(label: 'Filename', value: ts.filename),
                  SailStackedValueRow(
                    label: 'File Hash',
                    value: ts.fileHash,
                    action: _CopyIcon(onCopy: () => model.copyHash(context)),
                  ),
                  SailValueRow(label: 'Timestamped', value: formatConfirmedAt(ts, 'MMM d, yyyy HH:mm:ss')),
                  SailValueRow(label: 'Status', value: ts.status.toUpperCase()),
                  if (ts.status == 'confirming' || ts.status == 'confirmed')
                    SailValueRow(label: 'Confirmations', value: ts.confirmations.toString()),
                  if (ts.hasTxid())
                    SailStackedValueRow(
                      label: 'Transaction ID',
                      value: ts.txid,
                      action: _CopyIcon(onCopy: () => model.copyTxid(context)),
                    ),
                  if (ts.hasBlockHeight()) SailValueRow(label: 'Block Height', value: ts.blockHeight.toString()),
                ],
              ),
              const SizedBox(height: SailStyleValues.padding08),
              Align(
                alignment: Alignment.centerRight,
                child: SailButton(label: 'Close', onPressed: () async => GetIt.I.get<AppRouter>().pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyIcon extends StatelessWidget {
  final VoidCallback onCopy;

  const _CopyIcon({required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return SailButton(
      variant: ButtonVariant.icon,
      icon: SailSVGAsset.iconCopy,
      iconWidth: 16,
      onPressed: () async => onCopy(),
    );
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
        SailButton(
          variant: ButtonVariant.icon,
          icon: SailSVGAsset.iconCopy,
          iconWidth: 16,
          onPressed: () async => onCopy(),
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
