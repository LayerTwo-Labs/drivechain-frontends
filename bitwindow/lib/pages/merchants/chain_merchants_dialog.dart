import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class ChainMerchant {
  final String name;
  final String description;
  final String url;

  const ChainMerchant({
    required this.name,
    required this.description,
    required this.url,
  });
}

class ChainMerchantsDialog extends StatelessWidget {
  static const merchants = [
    ChainMerchant(
      name: 'BitRefill',
      description: 'Buy gift cards and mobile top-ups with Bitcoin',
      url: 'https://bitrefill.com',
    ),
    ChainMerchant(
      name: 'Shopify via BTCPay',
      description: 'E-commerce platform with Bitcoin payment integration',
      url: 'https://btcpayserver.org/shopify',
    ),
    ChainMerchant(
      name: 'Bare Bitcoin',
      description: 'Buy Bitcoin, but only if you live in Norway',
      url: 'https://barebitcoin.no',
    ),
    ChainMerchant(
      name: 'River',
      description: 'Buy Bitcoin, but only if you live in USA',
      url: 'https://river.com',
    ),
    // Add more merchants as needed
  ];

  const ChainMerchantsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Chain Merchants',
      subtitle: 'Merchants and services that accept Bitcoin payments',
      maxWidth: 600,
      child: SailStyleValues.phoneLayout(context)
          ? const _PhoneMerchantList(merchants: merchants)
          : SailTable(
              getRowId: (index) => index.toString(),
              headerBuilder: (context) => [
                const SailTableHeaderCell(name: 'Name'),
                const SailTableHeaderCell(name: 'Description'),
              ],
              rowBuilder: (context, index, selected) {
                final merchant = merchants[index];
                return [
                  SailTableCell(
                    value: merchant.name,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          await openUrl(Uri.parse(merchant.url));
                        },
                        child: SailText.primary12(
                          merchant.name,
                          color: context.sailTheme.colors.info,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SailTableCell(value: merchant.description),
                ];
              },
              rowCount: merchants.length,
              shrinkWrap: true,
              emptyPlaceholder: 'No merchants available',
              backgroundColor: context.sailTheme.colors.backgroundSecondary,
              onDoubleTap: (rowId) async {
                final index = int.parse(rowId);
                await openUrl(Uri.parse(merchants[index].url));
              },
            ),
    );
  }
}

class _PhoneMerchantList extends StatelessWidget {
  final List<ChainMerchant> merchants;

  const _PhoneMerchantList({required this.merchants});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return ListView.separated(
      shrinkWrap: true,
      itemCount: merchants.length,
      separatorBuilder: (context, index) => Container(height: 1, color: theme.colors.divider),
      itemBuilder: (context, index) {
        final merchant = merchants[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async => openUrl(Uri.parse(merchant.url)),
                child: SailText.primary13(merchant.name, color: theme.colors.primary, underline: true),
              ),
              const SizedBox(height: 2),
              SailText.secondary12(merchant.description),
            ],
          ),
        );
      },
    );
  }
}
