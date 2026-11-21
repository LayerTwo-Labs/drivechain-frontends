import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CashCheckSuccessPage extends StatelessWidget {
  final String txid;
  final int? amountSats;

  const CashCheckSuccessPage({
    super.key,
    @PathParam('txid') required this.txid,
    @QueryParam('amount') this.amountSats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final btcAmount = amountSats != null ? (amountSats! / 100000000).toStringAsFixed(8) : '0.00000000';

    return SailScaffold(
      backgroundColor: theme.colors.background,
      appBar: SailAppBar.build(context, automaticallyImplyLeading: false),
      body: SailStyleValues.phoneLayout(context)
          ? _PhoneCashedBody(txid: txid, amount: '$btcAmount ${activeTicker.symbol}')
          : SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: 800,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SailText.primary40(
                          'Your Check was Cashed',
                          bold: true,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SailText.primary15(
                          'Funds are on their way to your wallet',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        SailSVG.icon(
                          SailSVGAsset.iconSuccess,
                          width: 64,
                          height: 64,
                          color: theme.colors.success,
                        ),
                        const SizedBox(height: 30),
                        SailCard(
                          padding: true,
                          secondary: true,
                          child: SailColumn(
                            spacing: SailStyleValues.padding12,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailRow(
                                spacing: SailStyleValues.padding08,
                                children: [
                                  SailText.primary13('Amount:', bold: true),
                                  SailText.primary13('$btcAmount ${activeTicker.symbol}'),
                                ],
                              ),
                              SailRow(
                                spacing: SailStyleValues.padding08,
                                children: [
                                  SailText.primary13('Transaction:', bold: true),
                                  Flexible(
                                    child: SailText.primary12(
                                      '${txid.substring(0, 10)}...${txid.substring(txid.length - 10)}',
                                      color: theme.colors.textSecondary,
                                    ),
                                  ),
                                  CopyButton(text: txid),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SailButton(
                              label: 'Done',
                              variant: ButtonVariant.primary,
                              onPressed: () async {
                                await GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

Future<void> _done() => GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);

class _PhoneCashedBody extends StatelessWidget {
  final String txid;
  final String amount;

  const _PhoneCashedBody({required this.txid, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        child: SailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colors.success),
                  ),
                  const SizedBox(width: SailStyleValues.padding08),
                  Expanded(child: SailText.primary15('Your Check was Cashed', bold: true)),
                ],
              ),
              const SizedBox(height: SailStyleValues.padding08),
              SailText.secondary13('Funds are on their way to your wallet'),
              const SizedBox(height: SailStyleValues.padding08),
              Container(height: 1, color: theme.colors.divider),
              SailValueRow(label: 'Amount', value: amount),
              Container(height: 1, color: theme.colors.divider),
              SailValueRow(
                label: 'Transaction',
                value: '${txid.substring(0, 10)}...${txid.substring(txid.length - 10)}',
                valueColor: theme.colors.textSecondary,
                action: CopyButton(text: txid),
              ),
              Container(height: 1, color: theme.colors.divider),
              const SizedBox(height: SailStyleValues.padding12),
              Align(
                alignment: Alignment.centerRight,
                child: SailButton(label: 'Done', onPressed: _done),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
