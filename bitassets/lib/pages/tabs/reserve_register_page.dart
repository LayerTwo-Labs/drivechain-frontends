import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thirds/blake3.dart';

@RoutePage()
class BitAssetsTabPage extends StatelessWidget {
  const BitAssetsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final registerCardKey = GlobalKey();

    return QtPage(
      child: ViewModelBuilder<BitAssetsViewModel>.reactive(
        viewModelBuilder: () => BitAssetsViewModel(),
        builder: (context, model, child) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                SailCard(
                  title: 'All BitAssets',
                  subtitle: 'View and manage all registered bitassets',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    children: [
                      SailRow(
                        spacing: SailStyleValues.padding16,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: SailTextField(
                              hintText: 'Search bitassets...',
                              controller: model.searchController,
                            ),
                          ),
                          SailButton(
                            label: 'Register New BitAsset',
                            onPressed: () async {
                              // Scroll to the Register card
                              await Scrollable.ensureVisible(
                                registerCardKey.currentContext!,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: SailSkeletonizer(
                          description: 'Loading bitassets...',
                          enabled: model.isLoading,
                          child: SailTable(
                            getRowId: (index) => model.entries[index].hash,
                            headerBuilder: (context) => [
                              SailTableHeaderCell(name: 'Hash'),
                              SailTableHeaderCell(name: 'Plaintext Name'),
                              SailTableHeaderCell(name: 'Sequence ID'),
                              SailTableHeaderCell(name: 'Encryption Key'),
                              SailTableHeaderCell(name: 'Signing Key'),
                            ],
                            rowBuilder: (context, row, selected) {
                              final entry = model.entries[row];
                              final shortHash = '${entry.hash.substring(0, 10)}..';
                              return [
                                SailTableCell(
                                  value: shortHash,
                                  copyValue: entry.hash,
                                ),
                                SailTableCell(value: entry.plaintextName ?? '<unknown>'),
                                SailTableCell(value: entry.sequenceID.toString()),
                                SailTableCell(value: entry.details.encryptionPubkey ?? '-'),
                                SailTableCell(value: entry.details.signingPubkey ?? '-'),
                              ];
                            },
                            contextMenuItems: (rowId) {
                              final entry = model.entries.firstWhere((e) => e.hash == rowId);
                              return [
                                SailMenuItem(
                                  onSelected: () async {
                                    await showBitnameDetails(context, entry);
                                  },
                                  child: SailText.primary12('Show Details'),
                                ),
                              ];
                            },
                            rowCount: model.entries.length,
                            drawGrid: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Reserve & Register Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 800;
                    return SailRow(
                      spacing: SailStyleValues.padding16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SailCard(
                            title: 'Reserve',
                            subtitle: 'Reserve a new bitasset',
                            error: model.reserveError,
                            child: SailColumn(
                              spacing: SailStyleValues.padding16,
                              children: [
                                SailTextField(
                                  label: 'Plaintext Name',
                                  hintText: 'Enter name to reserve',
                                  controller: model.reserveNameController,
                                  enabled: !model.reserveLoading,
                                ),
                                SailButton(
                                  label: 'Reserve',
                                  onPressed: model.reserveLoading ? null : () => model.reserveBitname(context),
                                  loading: model.reserveLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 0 : SailStyleValues.padding16),
                        Expanded(
                          child: SailCard(
                            key: registerCardKey,
                            title: 'Register',
                            subtitle: 'Register a reserved bitasset',
                            error: model.registerError,
                            child: SailColumn(
                              spacing: SailStyleValues.padding16,
                              children: [
                                SailTextField(
                                  label: 'Plaintext Name',
                                  hintText: 'Enter name to register',
                                  controller: model.registerNameController,
                                ),
                                SailTextField(
                                  label: 'Initial Supply',
                                  hintText: 'Enter initial supply',
                                  controller: model.initialSupplyController,
                                ),
                                SailTextField(
                                  label: 'Commitment',
                                  hintText: 'Enter commitment',
                                  controller: model.commitmentController,
                                ),
                                SailTextField(
                                  label: 'IPv4 Address (optional)',
                                  hintText: 'Enter IPv4 address',
                                  controller: model.ipv4Controller,
                                ),
                                SailTextField(
                                  label: 'IPv6 Address (optional)',
                                  hintText: 'Enter IPv6 address',
                                  controller: model.ipv6Controller,
                                ),
                                SailCheckbox(
                                  label: 'Set Encryption Pubkey',
                                  value: model.useEncryptionKey,
                                  onChanged: (value) {
                                    model.useEncryptionKey = value;
                                    model.notifyListeners();
                                  },
                                ),
                                if (model.useEncryptionKey && model.encryptionKey != null)
                                  SailTextField(
                                    label: 'Encryption Pubkey',
                                    controller: TextEditingController(text: model.encryptionKey),
                                    hintText: 'Encryption Pubkey',
                                    readOnly: true,
                                  ),
                                SailCheckbox(
                                  label: 'Set Signing Pubkey',
                                  value: model.useSigningKey,
                                  onChanged: (value) {
                                    model.useSigningKey = value;
                                    model.notifyListeners();
                                  },
                                ),
                                if (model.useSigningKey && model.signingKey != null)
                                  SailTextField(
                                    label: 'Signing Pubkey',
                                    controller: TextEditingController(text: model.signingKey),
                                    hintText: 'Signing Pubkey',
                                    readOnly: true,
                                  ),
                                SailButton(
                                  label: 'Register',
                                  onPressed: model.registerLoading ? null : () => model.registerBitAsset(context),
                                  loading: model.registerLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReserveRegisterTab extends StatelessWidget {
  const ReserveRegisterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Reserve & Register',
      subtitle: 'Register a new bitasset',
      child: Center(
        child: SailText.primary13('Coming soon...'),
      ),
    );
  }
}

Future<void> showBitnameDetails(BuildContext context, BitAssetEntry entry) async {
  await Future.microtask(() async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SailCard(
                title: 'Bitname Details',
                subtitle: entry.hash,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailRow(label: 'Hash', value: entry.hash),
                      DetailRow(label: 'Sequence ID', value: entry.sequenceID.toString()),
                      if (entry.details.commitment != null)
                        DetailRow(label: 'Commitment', value: entry.details.commitment!),
                      if (entry.details.socketAddrV4 != null)
                        DetailRow(label: 'Socket Address (IPv4)', value: entry.details.socketAddrV4!),
                      if (entry.details.socketAddrV6 != null)
                        DetailRow(label: 'Socket Address (IPv6)', value: entry.details.socketAddrV6!),
                      if (entry.details.encryptionPubkey != null)
                        DetailRow(label: 'Encryption Public Key', value: entry.details.encryptionPubkey!),
                      if (entry.details.signingPubkey != null)
                        DetailRow(label: 'Signing Public Key', value: entry.details.signingPubkey!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  });
  return;
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SailText.primary13(
              label,
              monospace: true,
              color: context.sailTheme.colors.textTertiary,
            ),
          ),
          Expanded(
            child: SailText.secondary13(
              value,
              monospace: true,
            ),
          ),
        ],
      ),
    );
  }
}

class BitAssetsViewModel extends BaseViewModel {
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();
  final BitAssetsProvider provider = GetIt.I.get<BitAssetsProvider>();
  final BitAssetsRPC bitassetsRPC = GetIt.I.get<BitAssetsRPC>();

  String? reserveError;
  bool reserveLoading = false;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController reserveNameController = TextEditingController();
  final TextEditingController initialSupplyController = TextEditingController();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController commitmentController = TextEditingController();
  final TextEditingController ipv4Controller = TextEditingController();
  final TextEditingController ipv6Controller = TextEditingController();
  final TextEditingController paymailFeeController = TextEditingController();

  // Keys
  String? encryptionKey;
  String? signingKey;

  // Register state
  bool registerLoading = false;
  String? registerError;

  // New state variables
  bool useEncryptionKey = false;
  bool useSigningKey = false;

  BitAssetsViewModel() {
    searchController.addListener(notifyListeners);
    provider.addListener(notifyListeners);
    provider.fetch();
    reserveNameController.addListener(() {
      reserveError = null;
      notifyListeners();
    });

    generateKeysWithRetry();
  }

  Future<void> generateKeysWithRetry() async {
    encryptionKey = null;
    signingKey = null;

    while (encryptionKey == null || signingKey == null) {
      try {
        if (encryptionKey == null) {
          encryptionKey = await bitassetsRPC.getNewEncryptionKey();
          notifyListeners();
        }

        if (signingKey == null) {
          signingKey = await bitassetsRPC.getNewVerifyingKey();
          notifyListeners();
        }
      } catch (e) {
        // If there's an error, wait a bit before retrying
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  List<BitAssetEntry> get entries {
    final searchText = searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return provider.entries;
    }

    // Hash the search text with Blake3 using thirds package
    String? searchHash;
    try {
      searchHash = blake3Hex(utf8.encode(searchText));
    } catch (e) {
      // If hashing fails, continue with regular search
      searchHash = null;
    }

    return provider.entries.where((entry) {
      // Check if search text hash matches entry hash
      if (searchHash != null && entry.hash.toLowerCase() == searchHash.toLowerCase()) {
        return true;
      }

      // Search in hash
      if (entry.hash.toLowerCase().contains(searchText)) {
        return true;
      }
      // Search in sequence ID
      if (entry.sequenceID.toString().toLowerCase().contains(searchText)) {
        return true;
      }
      // Search in encryption key
      if (entry.details.encryptionPubkey?.toLowerCase().contains(searchText) ?? false) {
        return true;
      }
      // Search in signing key
      if (entry.details.signingPubkey?.toLowerCase().contains(searchText) ?? false) {
        return true;
      }
      // Search in socket address (IPv4)
      if (entry.details.socketAddrV4?.toLowerCase().contains(searchText) ?? false) {
        return true;
      }
      // Search in socket address (IPv6)
      if (entry.details.socketAddrV6?.toLowerCase().contains(searchText) ?? false) {
        return true;
      }
      // Search in commitment
      if (entry.details.commitment?.toLowerCase().contains(searchText) ?? false) {
        return true;
      }

      return false;
    }).toList();
  }

  bool get isLoading => !provider.initialized;

  Future<void> reserveBitname(BuildContext context) async {
    if (balanceProvider.balance < 0.00001000) {
      reserveError = 'Insufficient balance, deposit more funds on the Parent Chain tab to reserve a bitasset';
      notifyListeners();
      return;
    }

    final name = reserveNameController.text.trim();
    if (name.isEmpty) {
      reserveError = 'Name cannot be empty';
      notifyListeners();
      return;
    }
    reserveLoading = true;
    reserveError = null;
    notifyListeners();
    try {
      final txid = await bitassetsRPC.reserveBitAsset(name);
      reserveLoading = false;
      notifyListeners();
      if (context.mounted) {
        notificationProvider.add(
          title: 'Success',
          content: 'Bitname "$name" reserved successfully in $txid!',
          dialogType: DialogType.success,
        );
      }
      await provider.fetch();
      reserveNameController.clear();
    } catch (e) {
      reserveError = e.toString();
      reserveLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerBitAsset(BuildContext context) async {
    if (balanceProvider.balance < 0.00001000) {
      registerError = 'Insufficient balance, deposit more funds on the Parent Chain tab to register a bitasset';
      notifyListeners();
      return;
    }

    final name = registerNameController.text.trim();
    if (name.isEmpty) {
      registerError = 'Name cannot be empty';
      notifyListeners();
      return;
    }

    final initialSupply = int.tryParse(initialSupplyController.text.trim());
    if (initialSupply == null) {
      registerError = 'Initial supply must be set';
      notifyListeners();
      return;
    }

    final commitment = commitmentController.text.trim().isEmpty ? null : commitmentController.text.trim();
    final ipv4 = ipv4Controller.text.trim().isEmpty ? null : ipv4Controller.text.trim();
    final ipv6 = ipv6Controller.text.trim().isEmpty ? null : ipv6Controller.text.trim();

    registerLoading = true;
    registerError = null;
    notifyListeners();
    try {
      final txid = await bitassetsRPC.registerBitAsset(
        name,
        BitAssetRequest(
          initialSupply: initialSupply,
          commitment: commitment,
          encryptionPubkey: useEncryptionKey ? encryptionKey : null,
          signingPubkey: useSigningKey ? signingKey : null,
          socketAddrV4: ipv4,
          socketAddrV6: ipv6,
        ),
      );
      registerLoading = false;
      notifyListeners();
      if (context.mounted) {
        notificationProvider.add(
          title: 'Success',
          content: 'BitAsset "$name" with $initialSupply initial supply registered successfully in $txid!',
          dialogType: DialogType.success,
        );
      }
      await provider.fetch();
      registerNameController.clear();
      commitmentController.clear();
      ipv4Controller.clear();
      ipv6Controller.clear();
      useEncryptionKey = false;
      useSigningKey = false;

      await generateKeysWithRetry();
    } catch (e) {
      registerError = e.toString();
      registerLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    reserveNameController.dispose();
    registerNameController.dispose();
    commitmentController.dispose();
    ipv4Controller.dispose();
    ipv6Controller.dispose();
    provider.removeListener(notifyListeners);
    super.dispose();
  }
}
