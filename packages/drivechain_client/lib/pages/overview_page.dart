import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/api.dart';
import 'package:drivechain_client/util/currencies.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money2/money2.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExperimentalBanner(),
          const SizedBox(height: 16.0),
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
  final API api = GetIt.I.get<API>();

  BalancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: api.getBalance(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SailText.primary12(snapshot.error.toString());
        } else if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13(
                    'Balances',
                    bold: true,
                  ),
                  const SizedBox(height: 16.0),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailText.primary13('Available: '),
                        SailText.primary13(
                          Money.fromNumWithCurrency(
                            snapshot.data!.confirmedSatoshi.toDouble(),
                            satoshi,
                          ).toString(),
                          bold: true,
                        ),
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
                        SailText.primary13(
                          Money.fromNumWithCurrency(
                            snapshot.data!.pendingSatoshi.toDouble(),
                            satoshi,
                          ).toString(),
                          bold: true,
                        ),
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
                        SailText.primary13(
                          Money.fromNumWithCurrency(
                            snapshot.data!.pendingSatoshi.toDouble() + snapshot.data!.confirmedSatoshi.toDouble(),
                            satoshi,
                          ).toString(),
                          bold: true,
                        ),
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
                        50000,
                        CommonCurrencies().usd,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Sum of all balances converted to USD at current BTC price
                    SailText.primary13(
                      Money.fromNumWithCurrency(
                        (((snapshot.data!.confirmedSatoshi.toInt() + snapshot.data!.pendingSatoshi.toInt()) * 50000) *
                            0.00000001), // TODO: Get current BTC price
                        CommonCurrencies().usd,
                      ).format('S###,###.##'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const CircularProgressIndicator.adaptive(); // TODO: Skeleton loading?
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
        SailText.primary13(
          '${money.format('S###,###.##')}/BTC',
        ),
        const SizedBox(width: 8.0),
        SailScaleButton(
          onPressed: () {
            showSnackBar(context, 'Not implemented');
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
