import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class MultisigCompatibilityNote extends StatelessWidget {
  const MultisigCompatibilityNote({super.key});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      shadowSize: ShadowSize.none,
      // backgroundColor: Colors.amber.withOpacity(0.1),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.amber,
                size: 20,
              ),
              SailText.primary13(
                'Compatibility Note',
                bold: true,
              ),
            ],
          ),
          SailText.secondary12(
            'The enforcer wallet can track multisig UTXOs but cannot sign transactions '
            'for them due to descriptor compatibility differences (P2WPKH vs P2WSH). '
            'Use Bitcoin Core or external signing tools for spending multisig funds.',
          ),
        ],
      ),
    );
  }
}

class MultisigImplementationNote extends StatelessWidget {
  const MultisigImplementationNote({super.key});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Implementation Status',
      subtitle: 'Current multisig functionality status',
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusItem(
            context,
            'Create Multisig Groups',
            'Full Bitcoin Core integration with real descriptors',
            true,
          ),
          _buildStatusItem(
            context,
            'Fund Groups',
            'Generate real addresses using Bitcoin Core',
            true,
          ),
          _buildStatusItem(
            context,
            'Balance Tracking',
            'Real-time UTXO tracking via Bitcoin Core',
            true,
          ),
          _buildStatusItem(
            context,
            'Create Transactions',
            'Full PSBT workflow with signing support',
            true,
          ),
          _buildStatusItem(
            context,
            'Transaction History',
            'Coming in future updates',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String description,
    bool isComplete,
  ) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.pending,
          color: isComplete 
            ? context.sailTheme.colors.success 
            : Colors.amber,
          size: 20,
        ),
        Expanded(
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13(title, bold: true),
              SailText.secondary12(description),
            ],
          ),
        ),
      ],
    );
  }
}