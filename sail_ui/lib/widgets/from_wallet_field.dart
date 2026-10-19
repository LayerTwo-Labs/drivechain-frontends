import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

// Padding plus chevron that SailDropdownButton draws around its selection.
const double _dropdownChrome = 45;

/// Confirmed balances, in sats, of the wallets that can fund a transaction.
class FundingWalletBalances extends ChangeNotifier {
  final Map<String, int> _sats = {};
  bool _disposed = false;

  int? satsFor(String walletId) => _sats[walletId];

  Future<void> load(Iterable<String> walletIds) async {
    if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
      return;
    }
    final rpc = GetIt.I<OrchestratorRPC>().wallet;
    final fresh = <String, int>{};
    for (final walletId in walletIds.toList()) {
      final int sats;
      try {
        sats = (await rpc.getBalance(walletId)).confirmedSats.round();
      } catch (_) {
        // One unreadable wallet must not blank the balance of the others.
        continue;
      }
      if (_disposed) {
        return;
      }
      if (_sats[walletId] != sats) {
        fresh[walletId] = sats;
      }
    }
    if (fresh.isEmpty) {
      return;
    }
    _sats.addAll(fresh);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Picks the wallet that funds a transaction. It never changes the active one.
class WalletPicker extends StatefulWidget {
  final String? selectedWalletId;
  final ValueChanged<String> onChanged;

  /// The balances the picker loads and shows. The picker makes its own when null.
  final FundingWalletBalances? balances;

  const WalletPicker({
    super.key,
    required this.selectedWalletId,
    required this.onChanged,
    this.balances,
  });

  @override
  State<WalletPicker> createState() => _WalletPickerState();
}

class _WalletPickerState extends State<WalletPicker> {
  final WalletReaderProvider _walletReader = GetIt.I<WalletReaderProvider>();
  late final FundingWalletBalances _balances = widget.balances ?? FundingWalletBalances();
  Timer? _refreshTimer;
  String _lastWalletIds = '';

  @override
  void initState() {
    super.initState();
    _walletReader.addListener(_onWalletsChanged);
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => unawaited(_loadBalances()));
    unawaited(_loadBalances());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _walletReader.removeListener(_onWalletsChanged);
    if (widget.balances == null) {
      _balances.dispose();
    }
    super.dispose();
  }

  void _onWalletsChanged() {
    final ids = _wallets.map((w) => w.id).join(',');
    if (ids == _lastWalletIds) {
      return;
    }
    _lastWalletIds = ids;
    unawaited(_loadBalances());
  }

  List<WalletData> get _wallets => _walletReader.fundingWallets();

  Future<void> _loadBalances() => _balances.load(_wallets.map((w) => w.id));

  @override
  Widget build(BuildContext context) {
    final walletReader = _walletReader;

    return ListenableBuilder(
      listenable: Listenable.merge([walletReader, _balances]),
      builder: (context, _) {
        final wallets = _wallets;
        if (wallets.isEmpty) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // The trigger sizes to its content, so cap the wallet row to the
            // slot minus the chrome drawn around it.
            final rowWidth = constraints.hasBoundedWidth
                ? max(0.0, constraints.maxWidth - _dropdownChrome)
                : double.infinity;

            return SizedBox(
              width: double.infinity,
              child: SailDropdownButton<String>(
                value: widget.selectedWalletId,
                hint: 'Select a wallet',
                items: wallets
                    .map(
                      (wallet) => SailDropdownItem<String>(
                        value: wallet.id,
                        label: wallet.name,
                        // The closed button names the wallet alone. A balance
                        // there wraps over three lines and crowds the field.
                        triggerChild: SailRow(
                          spacing: SailStyleValues.padding08,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WalletBlobAvatar(gradient: wallet.gradient, size: 20),
                            Flexible(child: SailText.primary13(wallet.name)),
                          ],
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: rowWidth),
                          child: SailRow(
                            spacing: SailStyleValues.padding08,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WalletBlobAvatar(gradient: wallet.gradient, size: 20),
                              Flexible(child: SailText.primary13(wallet.name)),
                              if (_balances.satsFor(wallet.id) != null)
                                Flexible(
                                  child: SailText.secondary13(
                                    formatBitcoin(satoshiToBTC(_balances.satsFor(wallet.id)!)),
                                    monospace: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (walletId) {
                  if (walletId != null) {
                    widget.onChanged(walletId);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// A [WalletPicker] under a form label, for a send-style form row.
class FromWalletField extends StatelessWidget {
  final String? selectedWalletId;
  final ValueChanged<String> onChanged;
  final String label;
  final FundingWalletBalances? balances;

  const FromWalletField({
    super.key,
    required this.selectedWalletId,
    required this.onChanged,
    this.label = 'From Wallet',
    this.balances,
  });

  @override
  Widget build(BuildContext context) {
    if (GetIt.I<WalletReaderProvider>().fundingWallets().isEmpty) {
      return const SizedBox.shrink();
    }

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(label, bold: true),
        WalletPicker(selectedWalletId: selectedWalletId, onChanged: onChanged, balances: balances),
      ],
    );
  }
}
