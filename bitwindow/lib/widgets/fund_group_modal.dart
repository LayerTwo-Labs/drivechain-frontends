import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class FundGroupModal extends StatelessWidget {
  final List<MultisigGroup> groups;

  const FundGroupModal({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FundGroupModalViewModel>.reactive(
      viewModelBuilder: () => FundGroupModalViewModel(groups: groups),
      onViewModelReady: (model) => model.init(),
      builder: (context, viewModel, child) {
        if (viewModel.selectedGroup != null && viewModel.currentAddress.isNotEmpty) {
          return SailModal(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SailCard(
                title: 'Fund ${viewModel.selectedGroup!.name}',
                subtitle: 'Send Bitcoin to this address to fund the multisig group',
                child: SailColumn(
                  mainAxisSize: MainAxisSize.min,
                  spacing: SailStyleValues.padding16,
                  children: [
                    SailTextField(
                      label: 'Funding Address',
                      hintText: 'Funding address',
                      controller: TextEditingController(text: viewModel.currentAddress),
                      readOnly: true,
                      suffixWidget: CopyButton(text: viewModel.currentAddress),
                    ),
                    SailButton(
                      label: 'Close',
                      onPressed: () async => Navigator.of(context).pop(),
                      variant: ButtonVariant.secondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SailModal(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: SailCard(
            title: 'Select Multisig Group to Fund',
            subtitle: 'Choose which group you want to generate a funding address for',
            error: viewModel.modalError,
            child: SingleChildScrollView(
              child: SailColumn(
                mainAxisSize: MainAxisSize.min,
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.groups.isEmpty)
                    SailText.secondary12('No multisig groups available')
                  else
                    ...viewModel.groups.map(
                      (group) => SailCard(
                        shadowSize: ShadowSize.none,
                        child: SailRow(
                          children: [
                            Expanded(
                              child: SailColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: SailStyleValues.padding04,
                                children: [
                                  SailText.primary13(group.name),
                                  SailText.secondary12('${group.m} of ${group.n} multisig'),
                                  SailText.secondary12(
                                    'Balance: ${group.balance.toStringAsFixed(8)} ${activeTicker.symbol}',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: SailStyleValues.padding16),
                            SailButton(
                              label: 'Fund This Group',
                              // Address generation moves Core's cursor, so a
                              // second click would take a second address and
                              // then overwrite the first one's record.
                              disabled: viewModel.isBusy,
                              loading: viewModel.isBusy,
                              onPressed: () async => viewModel.selectGroup(group),
                              variant: ButtonVariant.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  SailButton(
                    label: 'Close',
                    onPressed: () async => Navigator.of(context).pop(),
                    variant: ButtonVariant.ghost,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FundGroupModalViewModel extends BaseViewModel {
  final List<MultisigGroup> groups;

  OrchestratorMultisigLoungeRPC get _multisigLounge => GetIt.I.get<OrchestratorRPC>().multisigLounge;
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  String? modalError;
  MultisigGroup? selectedGroup;
  String currentAddress = '';
  HDWalletProvider? _hdWalletProvider;

  FundGroupModalViewModel({required this.groups});

  bool get hasMnemonic => _hdWalletProvider?.mnemonic != null;
  String? get mnemonic => _hdWalletProvider?.mnemonic;

  Future<void> init() async {
    try {
      _hdWalletProvider = GetIt.I.get<HDWalletProvider>();

      if (!_hdWalletProvider!.isInitialized) {
        await _hdWalletProvider!.init();
      }

      if (_hdWalletProvider!.error != null) {
        modalError = 'Failed to load wallet mnemonic: ${_hdWalletProvider!.error}';
      } else if (_hdWalletProvider!.mnemonic == null) {
        modalError = 'Wallet mnemonic not available';
      }
    } catch (e) {
      modalError = 'Failed to initialize wallet: $e';
    }

    notifyListeners();
  }

  Future<void> selectGroup(MultisigGroup group) async {
    selectedGroup = group;
    modalError = null;
    setBusy(true);
    notifyListeners();

    try {
      currentAddress = await _generateMultisigAddress(group);
    } catch (e) {
      modalError = 'Failed to generate address: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String> _generateMultisigAddress(MultisigGroup group) async {
    try {
      // Load latest group state from backend RPC
      final groups = await MultisigStorage.loadGroups();
      final enhancedGroup = groups.firstWhere(
        (g) => g.id == group.id,
        orElse: () => throw Exception('Group not found'),
      );

      final walletId = _walletReader.activeWalletId;
      if (walletId == null) {
        throw Exception('No active wallet');
      }

      final walletName = enhancedGroup.watchWalletName ?? 'multisig_${enhancedGroup.id}';

      MultisigGroup updatedGroup = enhancedGroup;

      // Ensure the watch-only wallet exists, created from the standard
      // (Phase-1) descriptors. SyncGroup owns watch-wallet creation server-side.
      await _multisigLounge.syncGroup(group: multisigGroupToProto(enhancedGroup), walletId: walletId);

      // The group carries the standard descriptors; persist them if not yet
      // stored. These are the same descriptors SyncGroup imported.
      final descriptor = enhancedGroup.descriptorReceive;
      if (descriptor == null || descriptor.isEmpty) {
        final built = await MultisigDescriptorBuilder.buildWatchOnlyDescriptors(enhancedGroup);
        updatedGroup = enhancedGroup.copyWith(
          descriptorReceive: built.receive,
          descriptorChange: built.change,
          watchWalletName: walletName,
        );
      }

      final receiveAddresses = List<AddressInfo>.from(updatedGroup.addresses['receive'] ?? []);
      // Let the watch wallet hand out the address instead of deriving it at an
      // index of our own: Core only emits indices inside the descriptor range
      // SyncGroup imported, so the address is always one the wallet tracks.
      final wantNext = updatedGroup.nextReceiveIndex;

      Map<dynamic, dynamic>? receiveDescriptor;
      final descriptors = await bitcoindRpcCall('listdescriptors', wallet: walletName);
      if (descriptors is Map && descriptors['descriptors'] is List) {
        for (final d in descriptors['descriptors'] as List) {
          if (d is Map && d['active'] == true && d['internal'] != true) {
            receiveDescriptor = d;
            break;
          }
        }
      }
      final coreNext = (receiveDescriptor?['next'] is int) ? receiveDescriptor!['next'] as int : 0;

      // A group funded through the earlier deriveaddresses flow left Core's own
      // cursor at 0, so it would hand out addresses this group already holds.
      // Move the cursor in one call. One call per address would take over a
      // thousand round trips for a group at the old range boundary.
      if (receiveDescriptor != null && coreNext < wantNext) {
        // The range is a hard cap. A next_index outside it makes Core reject
        // the import, and the cursor would stay at 0 while we record a high
        // index — a reused address under the wrong label.
        final currentRange = receiveDescriptor['range'];
        var rangeEnd = wantNext + 100;
        if (currentRange is List && currentRange.length == 2 && currentRange[1] is int) {
          final existingEnd = currentRange[1] as int;
          if (existingEnd > rangeEnd) {
            rangeEnd = existingEnd;
          }
        }

        final imported = await bitcoindRpcCall(
          'importdescriptors',
          params: [
            [
              {
                'desc': receiveDescriptor['desc'],
                'active': true,
                'internal': false,
                'range': [0, rangeEnd],
                'next_index': wantNext,
                'timestamp': 'now',
              },
            ],
          ],
          wallet: walletName,
        );

        // A silent failure here hands out index 0 again, so read the result.
        if (imported is! List ||
            imported.isEmpty ||
            !(imported.first is Map && (imported.first as Map)['success'] == true)) {
          throw Exception('Could not move the watch wallet cursor to index $wantNext');
        }
      }

      final newAddress = await bitcoindRpcCall('getnewaddress', wallet: walletName);
      if (newAddress is! String || newAddress.isEmpty) {
        throw Exception('Failed to get a funding address from watch wallet $walletName');
      }

      // Core hands out the cursor it holds, so that is the index just used.
      int nextIndex = coreNext > wantNext ? coreNext : wantNext;
      if (nextIndex < 0) {
        nextIndex = 0;
      }

      receiveAddresses.add(AddressInfo(index: nextIndex, address: newAddress, used: false));

      final finalGroup = updatedGroup.copyWith(
        addresses: {'receive': receiveAddresses, 'change': updatedGroup.addresses['change'] ?? []},
        nextReceiveIndex: nextIndex + 1,
      );

      await MultisigStorage.saveGroups([finalGroup]);

      return newAddress;
    } catch (e) {
      rethrow;
    }
  }
}
