import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CashChequeSuccessPage extends StatelessWidget {
  final String txid;
  final int? amountSats;

  const CashChequeSuccessPage({
    super.key,
    @PathParam('txid') required this.txid,
    @QueryParam('amount') this.amountSats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final btcAmount = amountSats != null ? (amountSats! / 100000000).toStringAsFixed(8) : '0.00000000';

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
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
                    'Your Cheque was Cashed',
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
                            SailText.primary13('$btcAmount BTC'),
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
