import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SignPreviewModal extends StatefulWidget {
  final MultisigTransaction transaction;
  final MultisigGroup group;
  final Future<void> Function() onSignConfirm;

  const SignPreviewModal({
    super.key,
    required this.transaction,
    required this.group,
    required this.onSignConfirm,
  });

  @override
  State<SignPreviewModal> createState() => _SignPreviewModalState();
}

class _SignPreviewModalState extends State<SignPreviewModal> {
  bool _isSigning = false;

  Future<void> _handleSign() async {
    setState(() => _isSigning = true);
    
    try {
      await widget.onSignConfirm();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSigning = false);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final group = widget.group;
    
    final walletKeys = group.keys.where((key) => key.isWallet).toList();
    final unsignedWalletKeys = walletKeys.where((key) =>
        !tx.keyPSBTs.any((kp) => kp.keyId == key.xpub && kp.isSigned),).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: SailCard(
          title: 'Sign Transaction Preview',
          subtitle: 'Review transaction details before signing',
          withCloseButton: true,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransactionDetails(tx, group),
                
                _buildSigningDetails(tx, group, walletKeys, unsignedWalletKeys),
                
                _buildKeyStatus(tx, group),
                
                SailRow(
                  spacing: SailStyleValues.padding12,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Cancel',
                      onPressed: _isSigning ? null : () async => Navigator.of(context).pop(),
                      variant: ButtonVariant.ghost,
                    ),
                    SailButton(
                      label: 'Sign Transaction',
                      onPressed: _isSigning || unsignedWalletKeys.isEmpty ? null : _handleSign,
                      loading: _isSigning,
                      variant: ButtonVariant.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTransactionDetails(MultisigTransaction tx, MultisigGroup group) {
    return SailCard(
      shadowSize: ShadowSize.none,
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Transaction Details'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding16,
                  children: [
                    Expanded(
                      child: SailColumn(
                        spacing: SailStyleValues.padding04,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.secondary12('Transaction ID:'),
                          SailText.primary13(tx.shortId),
                        ],
                      ),
                    ),
                    SailColumn(
                      spacing: SailStyleValues.padding04,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.secondary12('Group:'),
                        SailText.primary13(group.name),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: SailStyleValues.padding08),
                Container(
                  height: 1,
                  color: context.sailTheme.colors.divider,
                ),
                const SizedBox(height: SailStyleValues.padding08),
                SailRow(
                  spacing: SailStyleValues.padding16,
                  children: [
                    Expanded(
                      child: SailColumn(
                        spacing: SailStyleValues.padding04,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.secondary12('Amount:'),
                          SailText.primary13('${tx.amount.toStringAsFixed(8)} BTC'),
                        ],
                      ),
                    ),
                    SailColumn(
                      spacing: SailStyleValues.padding04,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.secondary12('Fee:'),
                        SailText.primary13('${tx.fee.toStringAsFixed(8)} BTC'),
                      ],
                    ),
                  ],
                ),
                SailColumn(
                  spacing: SailStyleValues.padding04,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.secondary12('Destination:'),
                    SailText.primary13(tx.destination),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSigningDetails(MultisigTransaction tx, MultisigGroup group, 
      List<MultisigKey> walletKeys, List<MultisigKey> unsignedWalletKeys,) {
    return SailCard(
      shadowSize: ShadowSize.none,
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Signing Information'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding16,
                  children: [
                    SailColumn(
                      spacing: SailStyleValues.padding04,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.secondary12('Current Signatures:'),
                        SailText.primary13('${tx.signatureCount}/${group.m}'),
                      ],
                    ),
                    SailColumn(
                      spacing: SailStyleValues.padding04,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.secondary12('Wallet Keys Available:'),
                        SailText.primary13('${unsignedWalletKeys.length}'),
                      ],
                    ),
                  ],
                ),
                if (unsignedWalletKeys.isNotEmpty) ...[
                  const Divider(height: 16),
                  SailText.secondary12('Keys to be signed:'),
                  ...unsignedWalletKeys.map((key) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: SailRow(
                      children: [
                        Icon(
                          Icons.key,
                          size: 16,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 8),
                        SailText.primary12(key.owner),
                      ],
                    ),
                  ),),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStatus(MultisigTransaction tx, MultisigGroup group) {
    return SailCard(
      shadowSize: ShadowSize.none,
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary15('Key Status'),
          SailColumn(
            spacing: SailStyleValues.padding08,
            children: group.keys.map((key) {
              final keyPSBT = tx.keyPSBTs.firstWhere(
                (kp) => kp.keyId == key.xpub,
                orElse: () => KeyPSBTStatus(
                  keyId: key.xpub,
                  psbt: null,
                  isSigned: false,
                  signedAt: null,
                ),
              );
              
              final hasUnsignedPSBT = keyPSBT.psbt != null && !keyPSBT.isSigned;
              final isSigned = keyPSBT.isSigned;
              final isWalletKey = key.isWallet;
              
              Color statusColor;
              IconData statusIcon;
              String statusText;
              
              if (isSigned) {
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = 'Signed';
              } else if (hasUnsignedPSBT && isWalletKey) {
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                statusText = 'Ready to sign';
              } else if (hasUnsignedPSBT) {
                statusColor = Colors.grey;
                statusIcon = Icons.schedule;
                statusText = 'Awaiting external signature';
              } else {
                statusColor = Colors.grey;
                statusIcon = Icons.help_outline;
                statusText = 'No PSBT available';
              }
              
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(6),
                  color: statusColor.withValues(alpha: 0.05),
                ),
                child: SailRow(
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SailColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: SailStyleValues.padding04,
                        children: [
                          SailText.primary12(key.owner),
                          SailText.secondary12(statusText),
                        ],
                      ),
                    ),
                    if (isWalletKey)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SailText.secondary12('Wallet Key'),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}