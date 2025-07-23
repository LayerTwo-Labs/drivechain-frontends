import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

class MultisigGroup {
  final String id;
  final String name;
  final int n;
  final int m;
  final List<MultisigKey> keys;
  final int created;

  MultisigGroup({
    required this.id,
    required this.name,
    required this.n,
    required this.m,
    required this.keys,
    required this.created,
  });

  factory MultisigGroup.fromJson(Map<String, dynamic> json) => MultisigGroup(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        n: json['n'] ?? 0,
        m: json['m'] ?? 0,
        keys: (json['keys'] as List<dynamic>?)
                ?.map((k) => MultisigKey.fromJson(k))
                .toList() ??
            [],
        created: json['created'] ?? 0,
      );

  String get participantNames => keys.map((k) => k.owner).join(', ');
}

class MultisigLoungeTab extends StatefulWidget {
  const MultisigLoungeTab({super.key});

  @override
  State<MultisigLoungeTab> createState() => _MultisigLoungeTabState();
}

class _MultisigLoungeTabState extends State<MultisigLoungeTab> {
  List<MultisigGroup> _multisigGroups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMultisigGroups();
  }

  Future<void> _loadMultisigGroups() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final file = File(path.join(bitdriveDir, 'multisig.json'));

      if (!await file.exists()) {
        setState(() {
          _multisigGroups = [];
          _isLoading = false;
        });
        return;
      }

      final content = await file.readAsString();
      final List<dynamic> jsonGroups = json.decode(content);
      
      setState(() {
        _multisigGroups = jsonGroups
            .map((json) => MultisigGroup.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load multisig groups: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lounges section
            SailCard(
              title: 'Multisig Lounges',
              subtitle: 'Create and manage multi-signature wallets',
              error: _error,
              child: SizedBox(
                height: 300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SailTable(
                              getRowId: (index) => _multisigGroups.isNotEmpty 
                                  ? _multisigGroups[index].id 
                                  : 'empty$index',
                              headerBuilder: (context) => [
                                const SailTableHeaderCell(name: 'Name'),
                                const SailTableHeaderCell(name: 'ID'),
                                const SailTableHeaderCell(name: 'Total Keys'),
                                const SailTableHeaderCell(name: 'Keys Required'),
                                const SailTableHeaderCell(name: 'Participants'),
                              ],
                              rowBuilder: (context, row, selected) {
                                if (_multisigGroups.isEmpty) {
                                  return [
                                    const SailTableCell(value: 'No multisig groups yet'),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                  ];
                                }
                                
                                final group = _multisigGroups[row];
                                return [
                                  SailTableCell(value: group.name),
                                  SailTableCell(value: group.id.toUpperCase()),
                                  SailTableCell(value: group.n.toString()),
                                  SailTableCell(value: group.m.toString()),
                                  SailTableCell(value: group.participantNames),
                                ];
                              },
                              rowCount: _multisigGroups.isEmpty ? 1 : _multisigGroups.length,
                              drawGrid: true,
                            ),
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    Center(
                      child: SailButton(
                        label: 'Create New Lounge',
                        onPressed: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) => const CreateMultisigModal(),
                          );
                          
                          // Reload groups after modal closes
                          if (result != false) {
                            await _loadMultisigGroups();
                          }
                        },
                        variant: ButtonVariant.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Transaction History section
            SailCard(
              title: 'Transaction History',
              subtitle: 'View and manage multisig transactions',
              child: SizedBox(
                height: 300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SailTable(
                        getRowId: (index) => 'tx_empty$index',
                        headerBuilder: (context) => [
                          const SailTableHeaderCell(name: 'Lounge'),
                          const SailTableHeaderCell(name: 'MuTxid'),
                          const SailTableHeaderCell(name: 'Status'),
                          const SailTableHeaderCell(name: 'Action'),
                          const SailTableHeaderCell(name: 'Bitcoin Txid'),
                        ],
                        rowBuilder: (context, row, selected) {
                          return [
                            const SailTableCell(value: 'Multisig functionality coming soon...'),
                            const SailTableCell(value: ''),
                            const SailTableCell(value: ''),
                            const SailTableCell(value: ''),
                            const SailTableCell(value: ''),
                          ];
                        },
                        rowCount: 1,
                        drawGrid: true,
                      ),
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SailText.primary13('Transaction Tools'),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Create Transaction',
                          onPressed: null,
                          variant: ButtonVariant.secondary,
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Sign and Send',
                          onPressed: null,
                          variant: ButtonVariant.secondary,
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Finalize and Broadcast',
                          onPressed: null,
                          variant: ButtonVariant.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}