import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: SailCard(
          title: 'Chain Merchants',
          subtitle: 'Merchants and services that accept Bitcoin payments',
          withCloseButton: true,
          child: Column(
            children: [
              Expanded(
                child: SailTable(
                  getRowId: (index) => index.toString(),
                  headerBuilder: (context) => [
                    const SailTableHeaderCell(name: 'Name'),
                    const SailTableHeaderCell(name: 'Description'),
                  ],
                  rowBuilder: (context, index, selected) {
                    final merchant = merchants[index];
                    return [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(merchant.url);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          child: SailText.primary12(
                            merchant.name,
                            color: context.sailTheme.colors.info,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SailTableCell(value: merchant.description),
                    ];
                  },
                  rowCount: merchants.length,
                  columnWidths: const [150, 300],
                  backgroundColor: context.sailTheme.colors.backgroundSecondary,
                  onDoubleTap: (rowId) async {
                    final index = int.parse(rowId);
                    final url = Uri.parse(merchants[index].url);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
