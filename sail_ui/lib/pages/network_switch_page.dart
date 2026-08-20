import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Page shown when a sidechain app is launched on an unsupported network.
/// Drivechain is not enabled on mainnet/testnet yet, so sidechains can only
/// run on forknet, eCash, signet, or regtest.
@RoutePage()
class NetworkSwitchPage extends StatefulWidget {
  const NetworkSwitchPage({super.key});

  @override
  State<NetworkSwitchPage> createState() => _NetworkSwitchPageState();
}

class _NetworkSwitchPageState extends State<NetworkSwitchPage> {
  BitcoinConfProvider get _confProvider => GetIt.I.get<BitcoinConfProvider>();

  String _selectedNetworkId = 'signet';
  bool _isSwitching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to signet as the recommended network
    _selectedNetworkId = 'signet';
  }

  /// The row the selector shows. The catalog decides the rows, so the default
  /// may not be among them; the switch has to submit what the user sees, or it
  /// sends an id no row carries and the page pops as though it worked.
  String get _effectiveNetworkId {
    final options = _confProvider.drivechainNetworkOptions;
    if (options.isEmpty) {
      return _selectedNetworkId;
    }
    if (options.any((o) => o.id == _selectedNetworkId)) {
      return _selectedNetworkId;
    }
    return options.first.id;
  }

  Future<void> _handleSwitch() async {
    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    try {
      await _confProvider.swapNetworkById(context, _effectiveNetworkId);

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
                        'You must switch to Forknet, eCash, Signet, or Regtest to use sidechains.',
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
                        SailDropdownButton<String>(
                          value: _effectiveNetworkId,
                          items: [
                            for (final option in _confProvider.drivechainNetworkOptions)
                              SailDropdownItem<String>(
                                value: option.id,
                                label: option.id == 'signet'
                                    ? '${option.displayName} (Recommended)'
                                    : option.displayName,
                              ),
                          ],
                          onChanged: (String? id) async {
                            if (id != null) {
                              setState(() {
                                _selectedNetworkId = id;
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
