import 'package:auto_route/auto_route.dart' hide AutoRouterX;
import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:stacked/stacked.dart';

class CheckDetailViewModel extends BaseViewModel {
  Logger get log => GetIt.I.get<Logger>();
  final CheckProvider _checkProvider = GetIt.I.get<CheckProvider>();
  final TransactionProvider _transactionProvider = GetIt.I.get<TransactionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();
  final int checkId;

  Cheque? _check;
  bool _isLoading = false;
  @override
  String? modelError;

  Cheque? get check => _check;
  bool get isLoading => _isLoading;

  CheckDetailViewModel(this.checkId) {
    _loadCheck();
    _checkProvider.addListener(_onCheckProviderChanged);
  }

  void _onCheckProviderChanged() {
    _loadCheck();
  }

  Future<void> _loadCheck() async {
    _isLoading = true;
    notifyListeners();

    _check = await _checkProvider.getCheck(checkId);
    if (_check == null) {
      modelError = 'Check not found';
    } else if (!_check!.hasFundedTxid()) {
      _checkProvider.startPolling(checkId);
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _checkProvider.removeListener(_onCheckProviderChanged);
    super.dispose();
  }

  void copyAddress(BuildContext context) {
    if (_check != null) {
      Clipboard.setData(ClipboardData(text: _check!.address));
      showSnackBar(context, 'Address copied to clipboard');
    }
  }

  void copyTxid(BuildContext context, String txid) {
    Clipboard.setData(ClipboardData(text: txid));
    showSnackBar(context, 'Transaction ID copied to clipboard');
  }

  Future<void> fundWithWallet(BuildContext context) async {
    if (_check == null) return;

    final bitwindowRPC = GetIt.I.get<BitwindowRPC>();

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      final amountSats = _check!.expectedAmountSats.toInt();

      final txid = await bitwindowRPC.wallet.sendTransaction(
        walletId,
        {_check!.address: amountSats},
        feeSatPerVbyte: 10,
      );

      if (!context.mounted) return;

      showSnackBar(
        context,
        'Transaction sent! TXID: ${txid.substring(0, 10)}...',
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      showSnackBar(
        context,
        'Failed to fund check: $e',
      );
    }
  }

  Future<void> sweepCheck(BuildContext context) async {
    if (_check == null || !_check!.hasFundedTxid()) return;

    final destinationAddress = _transactionProvider.address;
    if (destinationAddress.isEmpty) {
      if (context.mounted) {
        showSnackBar(context, 'No receive address available');
      }
      return;
    }

    if (!_check!.hasPrivateKeyWif() || _check!.privateKeyWif.isEmpty) {
      if (context.mounted) {
        showSnackBar(context, 'Private key not available - wallet may be locked');
      }
      return;
    }

    try {
      final txid = await _checkProvider.sweepCheck(
        _check!.privateKeyWif,
        destinationAddress,
        10,
      );

      if (!context.mounted) return;

      showSnackBar(
        context,
        'Check swept! TXID: ${txid.substring(0, 10)}...',
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      if (e.toString().toLowerCase().contains('wallet is locked')) {
        final isEncrypted = await _walletReader.isWalletEncrypted();
        if (!context.mounted) return;
        if (isEncrypted) {
          await _showUnlockDialog(context);
          if (!context.mounted) return;
          if (_walletReader.isWalletUnlocked) {
            await sweepCheck(context);
          }
        } else {
          showSnackBar(context, 'Backend wallet not initialized. Please restart the app.');
        }
      } else {
        showSnackBar(context, 'Failed to sweep check: $e');
      }
    }
  }

  Future<void> _showUnlockDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    bool isUnlocking = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SailTheme.of(context).colors.background,
          title: SailText.primary15('Unlock Wallet'),
          content: SizedBox(
            width: 400,
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.secondary13('Enter your wallet password to sweep checks'),
                SailTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          actions: [
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async => Navigator.of(context).pop(),
            ),
            SailButton(
              label: 'Unlock',
              loading: isUnlocking,
              onPressed: () async {
                setState(() => isUnlocking = true);
                final success = await _walletReader.unlockWallet(passwordController.text);

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                } else {
                  setState(() => isUnlocking = false);
                  if (context.mounted) {
                    showSnackBar(context, 'Incorrect password');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );

    passwordController.dispose();
  }
}

@RoutePage()
class CheckDetailPage extends StatelessWidget {
  final int checkId;

  const CheckDetailPage({
    super.key,
    @PathParam('id') required this.checkId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckDetailViewModel>.reactive(
      viewModelBuilder: () => CheckDetailViewModel(checkId),
      builder: (context, model, child) {
        final amountBTC = model.check != null
            ? (model.check!.expectedAmountSats.toInt() / 100000000).toStringAsFixed(8)
            : '0.00000000';

        return Scaffold(
          backgroundColor: SailTheme.of(context).colors.background,
          appBar: AppBar(
            backgroundColor: SailTheme.of(context).colors.background,
            foregroundColor: SailTheme.of(context).colors.text,
            title: SailText.primary20('Check for $amountBTC BTC'),
          ),
          body: Builder(
            builder: (context) {
              if (model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (model.modelError != null || model.check == null) {
                return Center(
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailText.primary15(model.modelError ?? 'Check not found'),
                      SailButton(
                        label: 'Go Back',
                        onPressed: () async => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }

              final check = model.check!;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(SailStyleValues.padding40),
                      child: SailColumn(
                        spacing: SailStyleValues.padding20,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: check.hasFundedTxid()
                                            ? context.sailTheme.colors.success.withValues(alpha: 0.2)
                                            : context.sailTheme.colors.orange.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: check.hasFundedTxid()
                                            ? context.sailTheme.colors.success.withValues(alpha: 0.5)
                                            : context.sailTheme.colors.orange.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: check.hasFundedTxid()
                                            ? context.sailTheme.colors.success
                                            : context.sailTheme.colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: SailStyleValues.padding12),
                              SailText.primary13(
                                check.hasFundedTxid() ? 'Funded' : 'Awaiting funding',
                              ),
                            ],
                          ),
                          if (!check.hasFundedTxid())
                            Container(
                              padding: const EdgeInsets.all(SailStyleValues.padding20),
                              decoration: BoxDecoration(
                                color: context.sailTheme.colors.backgroundSecondary,
                                borderRadius: SailStyleValues.borderRadiusSmall,
                              ),
                              child: QrImageView(
                                data: check.address,
                                version: QrVersions.auto,
                                size: 200,
                                backgroundColor: context.sailTheme.colors.backgroundSecondary,
                              ),
                            ),
                          if (!check.hasFundedTxid())
                            SailRow(
                              spacing: SailStyleValues.padding08,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: SailText.primary13(
                                    check.address,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                CopyButton(text: check.address),
                              ],
                            ),
                          if (check.hasFundedTxid() && check.hasPrivateKeyWif() && check.privateKeyWif.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(SailStyleValues.padding16),
                              decoration: BoxDecoration(
                                color: context.sailTheme.colors.backgroundSecondary,
                                borderRadius: SailStyleValues.borderRadiusSmall,
                                border: Border.all(
                                  color: context.sailTheme.colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: SailColumn(
                                spacing: SailStyleValues.padding08,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SailSVG.icon(SailSVGAsset.iconWarning, width: 16),
                                      const SizedBox(width: SailStyleValues.padding08),
                                      SailText.primary13(
                                        'Private Key (WIF)',
                                        bold: true,
                                      ),
                                    ],
                                  ),
                                  SailText.secondary12(
                                    'Share this private key with the recipient. They can import it into most Bitcoin wallets to access the funds.',
                                  ),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: SelectableText(
                                          check.privateKeyWif,
                                          style: TextStyle(
                                            fontFamily: 'IBMPlexMono',
                                            fontSize: 12,
                                            color: context.sailTheme.colors.text,
                                          ),
                                        ),
                                      ),
                                      CopyButton(text: check.privateKeyWif),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          if (!check.hasFundedTxid())
                            SizedBox(
                              width: 400,
                              height: 64,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.sailTheme.colors.primary,
                                      context.sailTheme.colors.primary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () => model.fundWithWallet(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: SailText.primary15(
                                    'Fund with Wallet',
                                    color: Colors.white,
                                    bold: true,
                                  ),
                                ),
                              ),
                            ),
                          if (check.hasFundedTxid())
                            SizedBox(
                              width: 400,
                              height: 64,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.sailTheme.colors.success,
                                      context.sailTheme.colors.success,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () => model.sweepCheck(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: SailText.primary15(
                                    'Sweep Check to Wallet',
                                    color: Colors.white,
                                    bold: true,
                                  ),
                                ),
                              ),
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
      },
    );
  }
}
