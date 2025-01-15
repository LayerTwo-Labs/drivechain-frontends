import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class WalletButton extends StatefulWidget {
  const WalletButton({super.key});

  @override
  State<WalletButton> createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showModal() {
    // Remove existing overlay if any
    _removeOverlay();

    // Create and insert new overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: SailTheme.of(context).colors.backgroundSecondary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SailText.primary13('Wallet Details'),
                  const SizedBox(height: 16),
                  // Add your wallet content here
                  SailText.secondary12('Balance: 0.00 BTC'),
                  const SizedBox(height: 8),
                  SailText.secondary12('Address: bc1q...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SailScaleButton(
        style: SailButtonStyle.secondary,
        onPressed: () {
          if (_overlayEntry == null) {
            _showModal();
          } else {
            _removeOverlay();
          }
        },
        child: Tooltip(
          message: 'Wallet',
          child: SailPadding(
            padding: const EdgeInsets.only(
              right: SailStyleValues.padding10,
            ),
            child: Builder(
              builder: (context) {
                final theme = SailTheme.of(context);
                return SailSVG.fromAsset(
                  SailSVGAsset.iconWallet,
                  height: 20,
                  color: theme.colors.text,
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}
