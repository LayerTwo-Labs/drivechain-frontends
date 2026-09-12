import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/utils/commitment_validation.dart';
import 'package:sidechain_core/utils/data_server_address.dart';
import 'package:stacked/stacked.dart';
import 'package:thirds/blake3.dart';

@RoutePage()
class BitnamesTabPage extends StatelessWidget {
  const BitnamesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final registerCardKey = GlobalKey();

    return QtPage(
      child: ViewModelBuilder<BitnamesViewModel>.reactive(
        viewModelBuilder: () => BitnamesViewModel(),
        builder: (context, model, child) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                SailCard(
                  title: 'Your Bitnames',
                  subtitle: 'View your registered bitnames',
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
                              hintText: 'Search bitnames...',
                              controller: model.searchController,
                            ),
                          ),
                          SailButton(
                            label: 'Register New Bitname',
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
                        height: 200,
                        child: SailSkeletonizer(
                          description: 'Loading bitnames...',
                          enabled: model.isLoading,
                          child: SailTable(
                            getRowId: (index) => model.myEntries[index].hash,
                            headerBuilder: (context) => [
                              SailTableHeaderCell(name: 'Hash'),
                              SailTableHeaderCell(name: 'Plaintext Name'),
                              SailTableHeaderCell(name: 'Sequence ID'),
                              SailTableHeaderCell(name: 'Commitment'),
                              SailTableHeaderCell(name: 'Encryption Key'),
                              SailTableHeaderCell(name: 'Signing Key'),
                              SailTableHeaderCell(name: 'Paymail Fee'),
                            ],
                            rowBuilder: (context, row, selected) {
                              final entry = model.myEntries[row];
                              final shortHash = '${entry.hash.substring(0, 10)}..';
                              return [
                                SailTableCell(
                                  value: shortHash,
                                  copyValue: entry.hash,
                                ),
                                SailTableCell(value: entry.plaintextName ?? '<unknown>'),
                                SailTableCell(value: entry.details.seqId),
                                SailTableCell(value: entry.details.commitment ?? '-'),
                                SailTableCell(value: entry.details.encryptionPubkey ?? '-'),
                                SailTableCell(value: entry.details.signingPubkey ?? '-'),
                                SailTableCell(
                                  value: entry.details.paymailFeeSats?.toString() ?? '-',
                                ),
                              ];
                            },
                            contextMenuItems: (rowId) {
                              final entry = model.myEntries.firstWhereOrNull((e) => e.hash == rowId);
                              if (entry == null) return [];
                              return [
                                SailMenuItem(
                                  onSelected: () async {
                                    await showBitnameDetails(context, entry);
                                  },
                                  child: SailText.primary12('Show Details'),
                                ),
                              ];
                            },
                            rowCount: model.myEntries.length,
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
                            subtitle:
                                'Reserve a bitname you want without needing a ipv4/v6-address. Can be registered later, but only by you.',
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
                                  onPressed: () => model.reserveBitname(context),
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
                            subtitle: 'Register a reserved bitname',
                            error: model.registerError,
                            child: SailColumn(
                              spacing: SailStyleValues.padding16,
                              children: [
                                SailTextField(
                                  label: 'Name',
                                  hintText: 'Enter name to register',
                                  controller: model.registerNameController,
                                ),
                                SailCard(
                                  title: 'Where your record lives',
                                  subtitle:
                                      'Your server answers with your record. The chain holds the addresses below.',
                                  child: SailColumn(
                                    spacing: SailStyleValues.padding16,
                                    children: [
                                      const _LabelWithHelp(
                                        label: 'Quick Lookup With Domain',
                                        message:
                                            'Your server answers the JSON-RPC method bitname_commit with your '
                                            'email, your keys, anything you publish. The chain holds only a hash '
                                            'of that record.',
                                      ),
                                      SailRow(
                                        spacing: SailStyleValues.padding08,
                                        children: [
                                          Expanded(
                                            child: SailTextField(
                                              hintText: 'psztorc.com',
                                              controller: model.websiteController,
                                              loading: LoadingDetails(
                                                enabled: model.readLoading,
                                                description: 'Reading your server...',
                                              ),
                                              onSubmitted: (_) {
                                                model.readCommitmentFromServer();
                                              },
                                            ),
                                          ),
                                          SailButton(
                                            label: 'Get IP addresses',
                                            variant: ButtonVariant.secondary,
                                            loading: model.readLoading,
                                            onPressed: () => model.readCommitmentFromServer(),
                                          ),
                                        ],
                                      ),
                                      SailText.secondary13(
                                        'Reads the addresses behind the domain, and fills them in below. '
                                        'The chain never holds the domain.',
                                      ),
                                      SailTextField(
                                        label: 'IPv4 address',
                                        hintText: '203.0.113.7:6002',
                                        controller: model.ipv4Controller,
                                      ),
                                      SailTextField(
                                        label: 'IPv6 address',
                                        hintText: '[2606:4700:4700::1111]:6002',
                                        controller: model.ipv6Controller,
                                      ),
                                      const SailInfoBox(
                                        type: InfoType.info,
                                        text:
                                            'The chain holds the IPv4 and IPv6 addresses above. You can update '
                                            'them at any time after registering.',
                                      ),
                                      if (model.readError != null)
                                        SailText.primary13(
                                          model.readError!,
                                          color: SailTheme.of(context).colors.error,
                                        ),
                                      if (model.commitmentData != null) ...[
                                        SailText.primary13(
                                          'Your server answered with the following commitment',
                                          color: SailTheme.of(context).colors.success,
                                        ),
                                        SailTextField(
                                          hintText: '',
                                          controller: TextEditingController(text: model.commitmentData),
                                          readOnly: true,
                                          maxLines: 4,
                                          monospace: true,
                                        ),
                                        SailTextField(
                                          label: 'Commitment',
                                          hintText: '',
                                          controller: model.commitmentController,
                                          readOnly: true,
                                          monospace: true,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SailCard(
                                  title: 'Messages',
                                  subtitle: 'What a stranger pays to reach you, and the keys they use.',
                                  child: SailColumn(
                                    spacing: SailStyleValues.padding16,
                                    children: [
                                      const _LabelWithHelp(
                                        label: 'Message postage in sats',
                                        message:
                                            'The smallest payment you accept with a message. Somebody sends you a '
                                            'coin with a memo, and your wallet hides a message that pays less. '
                                            'Nobody pays this to a miner.',
                                      ),
                                      SailTextField(
                                        hintText: 'Minimum you accept per message',
                                        controller: model.paymailFeeController,
                                      ),
                                      SailRow(
                                        spacing: SailStyleValues.padding04,
                                        children: [
                                          SailCheckbox(
                                            label: 'Private messages',
                                            value: model.useEncryptionKey,
                                            onChanged: (value) {
                                              model.useEncryptionKey = value;
                                              model.notifyListeners();
                                            },
                                          ),
                                          SailTooltip(
                                            message: 'People can send you a message only you can read.',
                                            child: SailSVG.fromAsset(
                                              SailSVGAsset.circleHelp,
                                              color: SailTheme.of(context).colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (model.useEncryptionKey && model.encryptionKey != null)
                                        SailTextField(
                                          label: 'Encryption Pubkey',
                                          controller: TextEditingController(text: model.encryptionKey),
                                          hintText: 'Encryption Pubkey',
                                          readOnly: true,
                                        ),
                                      SailRow(
                                        spacing: SailStyleValues.padding04,
                                        children: [
                                          SailCheckbox(
                                            label: 'Signed messages',
                                            value: model.useSigningKey,
                                            onChanged: (value) {
                                              model.useSigningKey = value;
                                              model.notifyListeners();
                                            },
                                          ),
                                          SailTooltip(
                                            message: 'People can check that a message really comes from you.',
                                            child: SailSVG.fromAsset(
                                              SailSVGAsset.circleHelp,
                                              color: SailTheme.of(context).colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (model.useSigningKey && model.signingKey != null)
                                        SailTextField(
                                          label: 'Signing Pubkey',
                                          controller: TextEditingController(text: model.signingKey),
                                          hintText: 'Signing Pubkey',
                                          readOnly: true,
                                        ),
                                    ],
                                  ),
                                ),
                                SailButton(
                                  label: 'Register',
                                  onPressed: () => model.registerBitname(context),
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
                SailCard(
                  title: 'All Bitnames',
                  subtitle: 'View and manage all registered bitnames',
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
                              hintText: 'Search bitnames...',
                              controller: model.searchController,
                            ),
                          ),
                          SailButton(
                            label: 'Register New Bitname',
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
                          description: 'Loading bitnames...',
                          enabled: model.isLoading,
                          child: SailTable(
                            getRowId: (index) => model.entries[index].hash,
                            headerBuilder: (context) => [
                              SailTableHeaderCell(name: 'Hash'),
                              SailTableHeaderCell(name: 'Plaintext Name'),
                              SailTableHeaderCell(name: 'Sequence ID'),
                              SailTableHeaderCell(name: 'Commitment'),
                              SailTableHeaderCell(name: 'Encryption Key'),
                              SailTableHeaderCell(name: 'Signing Key'),
                              SailTableHeaderCell(name: 'Paymail Fee'),
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
                                SailTableCell(value: entry.details.seqId),
                                SailTableCell(value: entry.details.commitment ?? '-'),
                                SailTableCell(value: entry.details.encryptionPubkey ?? '-'),
                                SailTableCell(value: entry.details.signingPubkey ?? '-'),
                                SailTableCell(
                                  value: entry.details.paymailFeeSats?.toString() ?? '-',
                                ),
                              ];
                            },
                            contextMenuItems: (rowId) {
                              final entry = model.entries.firstWhereOrNull((e) => e.hash == rowId);
                              if (entry == null) return [];
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
      subtitle: 'Register a new bitname',
      child: Center(
        child: SailText.primary13('Coming soon...'),
      ),
    );
  }
}

Future<void> showBitnameDetails(BuildContext context, BitnameEntry entry) async {
  await Future.microtask(() async {
    if (!context.mounted) return;
    return showThemedDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: true,
          child: SailModal(
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
                    DetailRow(label: 'Sequence ID', value: entry.details.seqId),
                    if (entry.details.commitment != null)
                      DetailRow(label: 'Commitment', value: entry.details.commitment!),
                    if (entry.details.socketAddrV4 != null)
                      DetailRow(label: 'Socket Address (IPv4)', value: entry.details.socketAddrV4!),
                    if (entry.details.socketAddrV6 != null)
                      DetailRow(label: 'Socket Address (IPv6)', value: entry.details.socketAddrV6!),
                    if (entry.details.socketAddrHost != null)
                      DetailRow(label: 'Host', value: entry.details.socketAddrHost!),
                    if (entry.details.encryptionPubkey != null)
                      DetailRow(label: 'Encryption Public Key', value: entry.details.encryptionPubkey!),
                    if (entry.details.signingPubkey != null)
                      DetailRow(label: 'Signing Public Key', value: entry.details.signingPubkey!),
                    if (entry.details.paymailFeeSats != null)
                      DetailRow(label: 'Paymail Fee (sats)', value: entry.details.paymailFeeSats!.toString()),
                    if (entry.details.commitment != null) _ResolvedCommitment(bitname: entry.hash),
                  ],
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

class _LabelWithHelp extends StatelessWidget {
  final String label;
  final String message;

  const _LabelWithHelp({required this.label, required this.message});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding04,
      children: [
        SailText.primary13(label),
        SailTooltip(
          message: message,
          child: SailSVG.fromAsset(
            SailSVGAsset.circleHelp,
            color: SailTheme.of(context).colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ResolvedCommitment extends StatelessWidget {
  final String bitname;

  const _ResolvedCommitment({required this.bitname});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return FutureBuilder<ResolveCommitResult>(
      future: GetIt.I.get<BitnamesRPC>().resolveCommit(bitname),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return SailText.primary13(
            'Could not read the data: ${snapshot.error}',
            color: theme.colors.error,
          );
        }

        final result = snapshot.data!;
        return SailColumn(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailRow(label: 'Data from address', value: result.dataJson),
            SailText.primary13(
              result.matches
                  ? 'This data hashes to the commitment on the chain.'
                  : 'This data does not match the commitment on the chain.',
              color: result.matches ? theme.colors.success : theme.colors.error,
            ),
          ],
        );
      },
    );
  }
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

class BitnamesViewModel extends BaseViewModel {
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();
  final BitnamesProvider provider = GetIt.I.get<BitnamesProvider>();
  final BitnamesRPC bitnamesRPC = GetIt.I.get<BitnamesRPC>();

  String? reserveError;
  bool reserveLoading = false;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController reserveNameController = TextEditingController();
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

  // The JSON the address served, and the state of that read
  String? commitmentData;
  bool readLoading = false;
  String? readError;

  // The address the digest describes. A later edit makes the digest stale.
  String? commitmentAddress;

  // The address fields as the read left them. The chain holds these, and the
  // domain does not, so an edit to either one makes the digest stale.
  String? commitmentFields;

  // A bare domain gets the sidechain RPC port, which is 6000 + sidechain 2.
  static const int defaultDataPort = 6002;

  final TextEditingController websiteController = TextEditingController();

  BitnamesViewModel() {
    searchController.addListener(notifyListeners);
    provider.addListener(notifyListeners);
    provider.fetch();
    reserveNameController.addListener(() {
      reserveError = null;
      notifyListeners();
    });
    websiteController.addListener(dropStaleCommitment);
    ipv4Controller.addListener(dropStaleCommitment);
    ipv6Controller.addListener(dropStaleCommitment);

    generateKeysWithRetry();
  }

  Future<void> generateKeysWithRetry() async {
    encryptionKey = null;
    signingKey = null;

    while (encryptionKey == null || signingKey == null) {
      try {
        if (encryptionKey == null) {
          encryptionKey = await bitnamesRPC.getNewEncryptionKey();
          notifyListeners();
        }

        if (signingKey == null) {
          signingKey = await bitnamesRPC.getNewVerifyingKey();
          notifyListeners();
        }
      } catch (e) {
        // If there's an error, wait a bit before retrying
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  List<BitnameEntry> get entries {
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
        if (entry.plaintextName == null) {
          // we found a hash match, but it's not saved yet! Make sure to save it
          // to disk for easy access later
          unawaited(provider.saveHashNameMapping(searchText));
        }
        return true;
      }

      // Search in hash
      if (entry.hash.toLowerCase().contains(searchText)) {
        return true;
      }
      // Search in sequence ID
      if (entry.details.seqId.toLowerCase().contains(searchText)) {
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
      // Search in paymail fee
      if (entry.details.paymailFeeSats?.toString().contains(searchText) ?? false) {
        return true;
      }
      return false;
    }).toList();
  }

  List<BitnameEntry> get myEntries {
    return provider.entries.where((entry) {
      final mapping = provider.hashNameMapping.value[entry.hash];
      return mapping?.isMine ?? false;
    }).toList();
  }

  bool get isLoading => !provider.initialized;

  Future<void> reserveBitname(BuildContext context) async {
    if (balanceProvider.balance < 0.00001000) {
      reserveError = 'Insufficient balance, deposit more funds on the Parent Chain tab to reserve a bitname';
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
      final txid = await bitnamesRPC.reserveBitName(name);
      await provider.saveHashNameMapping(name, isMine: true);
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

  Future<void> registerBitname(BuildContext context) async {
    // A slow read leaves the button live, and a second press sends a second
    // registration transaction.
    if (registerLoading) {
      return;
    }
    registerLoading = true;
    registerError = null;
    notifyListeners();
    try {
      await _registerBitname(context);
    } finally {
      registerLoading = false;
      notifyListeners();
    }
    // generateKeysWithRetry never gives up, so it runs after the button frees.
    // The checkboxes stay off until it answers, so no stale key reaches a form.
    if (registerError == null) {
      useEncryptionKey = false;
      useSigningKey = false;
      notifyListeners();
      await generateKeysWithRetry();
    }
  }

  Future<void> _registerBitname(BuildContext context) async {
    if (balanceProvider.balance < 0.00001000) {
      registerError = 'Insufficient balance, deposit more funds on the Parent Chain tab to register a bitname';
      notifyListeners();
      return;
    }

    final name = registerNameController.text.trim();
    if (name.isEmpty) {
      registerError = 'Name cannot be empty';
      notifyListeners();
      return;
    }

    final address = dataAddress();
    if (address.isNotEmpty && commitmentAddress != address) {
      await readCommitmentFromServer();
      if (readError != null) {
        registerError = readError;
        notifyListeners();
        return;
      }
      if (commitmentAddress != address || commitmentFields != addressFields()) {
        registerError = 'The address changed while the read ran. Press Register again.';
        notifyListeners();
        return;
      }
    }

    final commitment = commitmentController.text.trim().isEmpty ? null : commitmentController.text.trim();
    final ipv4 = ipv4Controller.text.trim().isEmpty ? null : ipv4Controller.text.trim();
    final ipv6 = ipv6Controller.text.trim().isEmpty ? null : ipv6Controller.text.trim();

    final commitmentError = validateCommitment(commitment: commitment, website: null, ipv4: ipv4, ipv6: ipv6);
    if (commitmentError != null) {
      registerError = commitmentError;
      notifyListeners();
      return;
    }

    final paymailFeeText = paymailFeeController.text.trim();
    int? paymailFeeSats;
    if (paymailFeeText.isNotEmpty) {
      paymailFeeSats = int.tryParse(paymailFeeText);
      if (paymailFeeSats == null || paymailFeeSats < 0) {
        registerError = 'Paymail fee must be a whole number of sats, and zero or more';
        notifyListeners();
        return;
      }
    }

    try {
      final txid = await bitnamesRPC.registerBitName(
        name,
        BitNameData(
          commitment: commitment,
          encryptionPubkey: useEncryptionKey ? encryptionKey : null,
          paymailFeeSats: paymailFeeSats,
          signingPubkey: useSigningKey ? signingKey : null,
          socketAddrV4: ipv4,
          socketAddrV6: ipv6,
        ),
      );
      await provider.saveHashNameMapping(name, isMine: true);
      if (context.mounted) {
        notificationProvider.add(
          title: 'Success',
          content: 'Bitname "$name" registered successfully in $txid!',
          dialogType: DialogType.success,
        );
      }
      await provider.fetch();
      registerNameController.clear();
      websiteController.clear();
      commitmentController.clear();
      ipv4Controller.clear();
      ipv6Controller.clear();
      paymailFeeController.clear();
      useEncryptionKey = false;
      useSigningKey = false;
      commitmentData = null;
      readError = null;
    } catch (e) {
      registerError = e.toString();
    }
  }

  /// The fields the chain holds, as one value. A digest describes these.
  String addressFields() => '${ipv4Controller.text.trim()}|${ipv6Controller.text.trim()}';

  /// A digest describes one address. An edit makes it describe nothing.
  void dropStaleCommitment() {
    if (commitmentAddress == null) {
      return;
    }

    if (dataAddress() == commitmentAddress && addressFields() == commitmentFields) {
      return;
    }

    commitmentAddress = null;
    commitmentFields = null;
    commitmentData = null;
    commitmentController.clear();
    notifyListeners();
  }

  /// The address the lookup reads from. The domain wins, because the button
  /// looks a domain up. A typed address serves when no domain is set.
  String dataAddress() {
    final domain = hostWithPort(websiteController.text, defaultDataPort);
    if (domain != null) {
      return domain;
    }
    return dataServerAddress(
      website: '',
      ipv4: ipv4Controller.text,
      ipv6: ipv6Controller.text,
      defaultPort: defaultDataPort,
    );
  }

  Future<void> readCommitmentFromServer() async {
    final address = dataAddress();
    // A lookup owns the address fields only when it starts from a domain. A
    // typed address is the user's own, so the read leaves it alone.
    final fromDomain = hostWithPort(websiteController.text, defaultDataPort) != null;

    if (address.isEmpty) {
      readError = 'Set a website or an address first';
      notifyListeners();
      return;
    }

    readLoading = true;
    readError = null;
    notifyListeners();

    try {
      final result = await bitnamesRPC.readCommitment(address);
      // An edit during the read leaves the digest describing an address the
      // fields no longer hold.
      if (dataAddress() != address) {
        return;
      }
      // The chain holds a socket address, so the lookup writes what it reached
      // into the fields the user sends. A family the lookup did not reach must
      // not keep the address of a server the user left behind. Both writes run
      // before the digest, because each one drops a stale digest.
      if (fromDomain) {
        ipv4Controller.text = result.socketAddrV4;
        ipv6Controller.text = result.socketAddrV6;
      }
      commitmentData = result.dataJson;
      commitmentAddress = address;
      commitmentFields = addressFields();
      commitmentController.text = result.commitment;
    } catch (e) {
      if (dataAddress() != address) {
        return;
      }
      commitmentAddress = null;
      commitmentFields = null;
      commitmentData = null;
      commitmentController.clear();
      readError = e.toString();
    } finally {
      readLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    reserveNameController.dispose();
    registerNameController.dispose();
    websiteController.dispose();
    commitmentController.dispose();
    ipv4Controller.dispose();
    ipv6Controller.dispose();
    paymailFeeController.dispose();
    provider.removeListener(notifyListeners);
    super.dispose();
  }
}
