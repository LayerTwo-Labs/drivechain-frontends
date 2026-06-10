import 'package:bitwindow/utils/merkle_tree.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

/// Merkle Tree Visualizer Dialog - Calculate and visualize Bitcoin Merkle trees
///
/// Qt equivalent: merkletreedialog.ui (size: 1213x780)
/// Tabs: Merkle Tree, Witness Merkle Tree, Help
/// Features: RCB (Reversed Concatenated Bytes) toggle for manual verification
class MerkleTreeDialog extends StatefulWidget {
  final List<String>? initialTxids;
  final String? expectedRoot;

  const MerkleTreeDialog({
    super.key,
    this.initialTxids,
    this.expectedRoot,
  });

  @override
  State<MerkleTreeDialog> createState() => _MerkleTreeDialogState();
}

class _MerkleTreeDialogState extends State<MerkleTreeDialog> {
  final TextEditingController _txidsController = TextEditingController();

  List<List<String>>? _tree;
  List<List<String>>? _rcbTree;
  String? _error;
  bool _showRCB = true; // Qt default is checked

  @override
  void initState() {
    super.initState();
    // Auto-populate if initial TxIDs provided
    if (widget.initialTxids != null && widget.initialTxids!.isNotEmpty) {
      _txidsController.text = widget.initialTxids!.join('\n');
      // Auto-calculate on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTree();
      });
    }
  }

  @override
  void dispose() {
    _txidsController.dispose();
    super.dispose();
  }

  void _calculateTree() {
    setState(() {
      _error = null;
      _tree = null;
      _rcbTree = null;

      final input = _txidsController.text.trim();
      if (input.isEmpty) {
        _error = 'Please enter transaction IDs (one per line)';
        return;
      }

      // Parse transaction IDs (one per line)
      final txids = input.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

      if (txids.isEmpty) {
        _error = 'Please enter at least one transaction ID';
        return;
      }

      // Validate hex format
      for (final txid in txids) {
        if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(txid)) {
          _error = 'Invalid transaction ID format: $txid\n(must be 64 hex characters)';
          return;
        }
      }

      // Calculate tree
      try {
        _tree = MerkleTree.calculate(txids);
        if (_showRCB) {
          _rcbTree = MerkleTree.calculateRCB(txids);
        }
      } catch (e) {
        _error = 'Failed to calculate Merkle tree: $e';
      }
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showSailToast(context, '$label copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Qt dialog size: 1213x780
    return SailModal(
      child: Container(
        width: 1200,
        constraints: const BoxConstraints(maxHeight: 800),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadiusSmall,
          border: Border.all(color: theme.colors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - matches Qt dialog title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary20('Merkle Tree'), // Qt windowTitle
                  SailTappable(
                    onTap: () async => Navigator.of(context).pop(),
                    borderRadius: SailStyleValues.borderRadiusSmall,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: SailSVG.fromAsset(SailSVGAsset.x, color: theme.colors.text),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            // Content - Qt QVBoxLayout with tabs
            Expanded(
              child: InlineTabBar(
                initialIndex: 0,
                tabs: [
                  TabItem(
                    label: 'Merkle Tree',
                    child: _TreeTab(
                      txidsController: _txidsController,
                      tree: _tree,
                      rcbTree: _rcbTree,
                      error: _error,
                      expectedRoot: widget.expectedRoot,
                      onCalculate: _calculateTree,
                      onCopy: _copyToClipboard,
                      onInputChanged: () {
                        if (_tree != null || _error != null) {
                          setState(() {
                            _tree = null;
                            _rcbTree = null;
                            _error = null;
                          });
                        }
                      },
                    ),
                  ),
                  const TabItem(label: 'Help', child: _HelpTab()),
                ],
              ),
            ),

            // Footer - RCB checkbox and Close button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SailCheckbox(
                        value: _showRCB,
                        onChanged: (value) {
                          setState(() {
                            _showRCB = value;
                            if (_tree != null) {
                              _rcbTree = _showRCB
                                  ? MerkleTree.calculateRCB(
                                      _txidsController.text
                                          .split('\n')
                                          .map((line) => line.trim())
                                          .where((line) => line.isNotEmpty)
                                          .toList(),
                                    )
                                  : null;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      SailText.secondary13('Display RCB'),
                      const SizedBox(width: 8),
                      SailTooltip(
                        message:
                            'Reversed & Concatenated Bytes\n'
                            'Used for manual verification with hash calculators',
                        child: SailSVG.fromAsset(SailSVGAsset.info, width: 16, color: theme.colors.textSecondary),
                      ),
                    ],
                  ),
                  SailButton(
                    label: 'Close',
                    variant: ButtonVariant.secondary,
                    onPressed: () async => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeTab extends StatelessWidget {
  final TextEditingController txidsController;
  final List<List<String>>? tree;
  final List<List<String>>? rcbTree;
  final String? error;
  final String? expectedRoot;
  final VoidCallback onCalculate;
  final void Function(String text, String label) onCopy;
  final VoidCallback onInputChanged;

  const _TreeTab({
    required this.txidsController,
    required this.tree,
    required this.rcbTree,
    required this.error,
    required this.expectedRoot,
    required this.onCalculate,
    required this.onCopy,
    required this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: SailStyleValues.borderRadiusSmall,
              border: Border.all(color: theme.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SailSVG.fromAsset(SailSVGAsset.folderTree, width: 20, color: theme.colors.primary),
                    const SizedBox(width: 8),
                    SailText.primary15('Transaction IDs', bold: true),
                  ],
                ),
                const SizedBox(height: 12),
                SailText.secondary12(
                  'Enter transaction IDs (TxIDs) one per line - 64 hex characters each',
                ),
                const SizedBox(height: 16),
                SailTextField(
                  controller: txidsController,
                  hintText:
                      'bd3a498beaca2b118b90f372c03ddf926cf167c3d97db260f4be32e3973a4ac1\n'
                      '7c1a4b6f9a2e3d8c5b4a3f2e1d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d1c',
                  monospace: true,
                  minLines: 8,
                  maxLines: 8,
                  onChanged: (_) => onInputChanged(),
                ),
                const SizedBox(height: 16),
                SailButton(
                  onPressed: () async => onCalculate(),
                  label: 'Calculate Merkle Tree',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error display
          if (error != null) ...[
            SailAlert(
              variant: SailAlertVariant.destructive,
              icon: SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 24, color: theme.colors.error),
              description: error!,
            ),
            const SizedBox(height: 24),
          ],

          // Tree display
          if (tree != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: SailStyleValues.borderRadiusSmall,
                border: Border.all(color: theme.colors.success, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SailSVG.fromAsset(SailSVGAsset.circleCheck, width: 24, color: theme.colors.success),
                          const SizedBox(width: 8),
                          SailText.primary15('Merkle Tree', bold: true),
                        ],
                      ),
                      SailTooltip(
                        message: 'Copy tree to clipboard',
                        child: SailTappable(
                          onTap: () async => () {
                            final treeText = MerkleTree.formatTreeText(tree!, rcbTree: rcbTree);
                            onCopy(treeText, 'Merkle tree');
                          }(),
                          borderRadius: SailStyleValues.borderRadiusSmall,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SailSVG.fromAsset(SailSVGAsset.copy, color: theme.colors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Display merkle root prominently
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colors.success.withValues(alpha: 0.1),
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      border: Border.all(color: theme.colors.success),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailText.primary13('Merkle Root:', bold: true),
                        const SizedBox(height: 8),
                        SailSelectableText(
                          tree!.last.first,
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 13,
                            color: theme.colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Validation against expected root (if provided)
                  if (expectedRoot != null) ...[
                    Builder(
                      builder: (context) {
                        final calculatedRoot = tree!.last.first;
                        final isValid = calculatedRoot.toLowerCase() == expectedRoot!.toLowerCase();

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isValid ? theme.colors.success : theme.colors.error).withValues(alpha: 0.1),
                            borderRadius: SailStyleValues.borderRadiusSmall,
                            border: Border.all(
                              color: isValid ? theme.colors.success : theme.colors.error,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SailSVG.fromAsset(
                                    isValid ? SailSVGAsset.circleCheck : SailSVGAsset.circleAlert,
                                    width: 24,
                                    color: isValid ? theme.colors.success : theme.colors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  SailText.primary15(
                                    isValid ? 'Merkle root matches block header ✓' : 'Merkle root MISMATCH ✗',
                                    bold: true,
                                    color: isValid ? theme.colors.success : theme.colors.error,
                                  ),
                                ],
                              ),
                              if (!isValid) ...[
                                const SizedBox(height: 16),
                                SailText.primary13('Expected:', bold: true),
                                const SizedBox(height: 4),
                                SailSelectableText(
                                  expectedRoot!,
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 12,
                                    color: theme.colors.text,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SailText.primary13('Calculated:', bold: true),
                                const SizedBox(height: 4),
                                SailSelectableText(
                                  calculatedRoot,
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 12,
                                    color: theme.colors.text,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Display full tree
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colors.backgroundSecondary,
                      borderRadius: SailStyleValues.borderRadiusSmall,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SailSelectableText(
                        MerkleTree.formatTreeText(tree!, rcbTree: rcbTree),
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 11,
                          color: theme.colors.text,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpTab extends StatelessWidget {
  const _HelpTab();

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: SailStyleValues.borderRadiusSmall,
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SailSVG.fromAsset(SailSVGAsset.circleHelp, width: 24, color: theme.colors.primary),
                const SizedBox(width: 8),
                SailText.primary15('How to Use the Merkle Tree Visualizer', bold: true),
              ],
            ),
            const SizedBox(height: 20),

            SailSelectableText(
              'This window allows you to audit the "hashMerkleRoot" field. '
              'You can see each step of the process yourself.\n\n'
              '         MerkleRoot = hashZ\n\n'
              '                hashZ\n'
              '               /    \\\n'
              '              /      \\\n'
              '           hashX       hashY |\n'
              '           /   \\         \\\n'
              '          /     \\         \\\n'
              '         /       \\         \\\n'
              '     hashF       hashG  |   hashH\n'
              '    /   \\       /     \\      \\\n'
              'hashA  hashB | hashC  hashD | hashE\n\n'
              'Notes:\n'
              '1. hashF = Sha256D ( hashA, hashB )\n'
              '   Each node in the tree is the hash of the two nodes beneath it.\n\n'
              '2. hashY = Sha256D ( hashH, hashH )\n'
              '   If there is an odd number of nodes at that level, the final node is hashed with itself.\n\n'
              '3. Hashes A through E are TxIDs -- the hashes of each transaction.\n\n'
              'Use the Hash Calculator to check that the Sha256D hash of the first two TxIDs '
              'is the value one level above it. And so on ad infinitum.',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 13,
                color: theme.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            SailText.primary15('What is RCB?', bold: true),
            const SizedBox(height: 12),
            SailSelectableText(
              'Computers sometimes have a crazy way of reading from their computer memory, '
              'related to something called "endianness".\n\n'
              'For whatever reason, Bitcoin merkle root hash calculations run like this:\n\n'
              'Hashes:          ... | hash01 hash02 | ...\n'
              'Reversed Bytes:  ... | 01shha 02shha | ...\n'
              'Next Level:      ... | Sha256D("01shha02shha") | ...\n\n'
              'For convenience, we provide both the "original bytes" and the "Reversed Concatenated" bytes (RCB).\n'
              'You can just paste the latter into our Sha256D Hash Calculator.\n\n'
              'If you want to do everything yourself, copy one TxID, reverse the hex using our hash calculator '
              '"flip hex" button and do the same to the second TxID. Concatenate the reversed hashes and then '
              'paste that into the Sha256D section of the hash calculator to calculate one hash for the next level of the tree.',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 13,
                color: theme.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            SailText.primary15('Further Reading', bold: true),
            const SizedBox(height: 12),
            SailSelectableText(
              '• https://en.bitcoinwiki.org/wiki/Merkle_tree\n'
              '• https://www.investopedia.com/terms/m/merkle-tree.asp\n'
              '• https://www.geeksforgeeks.org/introduction-to-merkle-tree/',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 13,
                color: theme.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
