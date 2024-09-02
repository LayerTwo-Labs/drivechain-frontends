import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/service.dart';
import 'package:drivechain_client/util/currencies.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExperimentalBanner(),
          SizedBox(height: 16.0),
          BalancesView(),
        ],
      ),
    );
  }
}

class ExperimentalBanner extends StatelessWidget {
  const ExperimentalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: SailTheme.of(context).colors.yellow.withOpacity(0.8),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(4.0),
      child: SailText.primary12(
        'This is experimental sidechain software. Use at your own risk!',
        bold: true,
      ),
    );
  }
}

class BalancesView extends StatelessWidget {
  const BalancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DrivechainService.of(context).getBalance(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SailText.primary12(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final theme = SailTheme.of(context);
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Balances",
                      style: SailStyleValues.thirteen.copyWith(
                        color: theme.colors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary13('Available: '),
                        RichText(
                            text: TextSpan(
                          text: Money.fromNumWithCurrency(
                            snapshot.data!.confirmedSatoshi.toDouble(),
                            satoshi,
                          ).toString(),
                          style: SailStyleValues.thirteen.copyWith(
                            color: theme.colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary13('Pending: '),
                        RichText(
                            text: TextSpan(
                          text: Money.fromNumWithCurrency(
                            snapshot.data!.pendingSatoshi.toDouble(),
                            satoshi,
                          ).toString(),
                          style: SailStyleValues.thirteen.copyWith(
                            color: theme.colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const QtSeparator(width: 150),
                  const SizedBox(height: 24.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary13('Total: '),
                        RichText(
                            text: TextSpan(
                          text: Money.fromNumWithCurrency(
                            snapshot.data!.pendingSatoshi.toDouble() +
                                snapshot.data!.confirmedSatoshi.toDouble(),
                            satoshi,
                          ).toString(),
                          style: SailStyleValues.thirteen.copyWith(
                            color: theme.colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BitcoinPrice(
                      money: Money.fromNumWithCurrency(
                          50000, CommonCurrencies().usd),
                    ),
                    const SizedBox(height: 16.0),
                    // Sum of all balances converted to USD at current BTC price
                    RichText(
                      text: TextSpan(
                        text: Money.fromNumWithCurrency(
                          (((snapshot.data!.confirmedSatoshi.toInt() +
                                      snapshot.data!.pendingSatoshi.toInt()) *
                                  50000) *
                              0.00000001), // TODO: Get current BTC price
                          CommonCurrencies().usd,
                        ).format('S###,###.##'),
                        style: SailStyleValues.thirteen
                            .copyWith(color: theme.colors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const LoadingIndicator(); // TODO: Skeleton loading?
      },
    );
  }
}

class QtSeparator extends StatelessWidget {
  final double width;

  const QtSeparator({
    super.key,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
      ),
      child: Container(
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 0.36, 1.0],
            colors: [
              Colors.grey,
              Colors.grey.withOpacity(0.3),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }
}

class BitcoinPrice extends StatelessWidget {
  final Money money;

  const BitcoinPrice({super.key, required this.money});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            //text: '${NumberFormat.currency(symbol: '\$').format(price)}/BTC',
            text: '${money.format('S###,###.##')}/BTC',
            style: SailStyleValues.thirteen.copyWith(
              color: SailTheme.of(context).colors.text,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        SailScaleButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Not implemented'),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Icon(Icons.settings),
          ),
        ),
      ],
    );
  }
}
