import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Page shown when a sidechain app is launched on an unsupported network.
/// Drivechain is not enabled on mainnet/testnet yet, so sidechains can only
/// run on forknet, signet, or regtest.
@RoutePage()
class NetworkSwitchPage extends StatefulWidget {
  const NetworkSwitchPage({super.key});

  @override
  State<NetworkSwitchPage> createState() => _NetworkSwitchPageState();
}

class _NetworkSwitchPageState extends State<NetworkSwitchPage> {
  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();

  BitcoinNetwork _selectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  bool _isSwitching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to signet as the recommended network
    _selectedNetwork = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
  }

  Future<void> _handleSwitch() async {
    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    try {
      await _confProvider.swapNetwork(context, _selectedNetwork);

      if (mounted) {
        context.router.pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error switching network: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final currentNetwork = _confProvider.network.toDisplayName();

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
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
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      SailText.primary40(
                        'Drivechains Not Enabled',
                        bold: true,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SailText.primary15(
                        'Drivechains are not enabled on $currentNetwork yet.\n'
                        'You must switch to Forknet, Signet, or Regtest to use sidechains.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                  const Spacer(),
                  // Network selector
                  SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SailText.secondary13(
                          'Select a network with drivechain support:',
                        ),
                        const SizedBox(height: 16),
                        SailDropdownButton<BitcoinNetwork>(
                          value: _selectedNetwork,
                          items: [
                            SailDropdownItem<BitcoinNetwork>(
                              value: BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
                              label: 'Signet (Recommended)',
                            ),
                            SailDropdownItem<BitcoinNetwork>(
                              value: BitcoinNetwork.BITCOIN_NETWORK_FORKNET,
                              label: 'Forknet',
                            ),
                            SailDropdownItem<BitcoinNetwork>(
                              value: BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
                              label: 'Regtest',
                            ),
                          ],
                          onChanged: (BitcoinNetwork? network) async {
                            if (network != null) {
                              setState(() {
                                _selectedNetwork = network;
                              });
                            }
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          SailText.secondary12(
                            _errorMessage!,
                            color: theme.colors.error,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Spacer(),
                  const Spacer(),
                  // Switch button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailButton(
                        label: 'Switch Network',
                        variant: ButtonVariant.primary,
                        loading: _isSwitching,
                        onPressed: _handleSwitch,
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
