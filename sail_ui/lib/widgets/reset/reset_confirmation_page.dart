import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Three-state header shown above the file list on the reset page.
/// Pre-deletion = red warning. Complete with zero errors = green check.
/// Complete with errors = orange warning, so partial wipes don't masquerade
/// as a clean success (#1723).
enum ResetHeaderState { confirm, success, partial }

ResetHeaderState resetHeaderState({required bool deletionComplete, required int errorCount}) {
  if (!deletionComplete) return ResetHeaderState.confirm;
  return errorCount == 0 ? ResetHeaderState.success : ResetHeaderState.partial;
}

/// Route-driven reset page. Callers push it with [request] describing WHAT to
/// delete (per-binary categories); the page gathers the concrete paths from the
/// orchestrator for the overview, then deletes them via the orchestrator on
/// confirm. Wallet paths are moved to wallet_backups/ server-side, not removed.
class ResetConfirmationPage extends StatefulWidget {
  final List<SingleDeletion> request;
  final Directory appDir;
  final BinaryProvider binaryProvider;
  final Logger log;

  const ResetConfirmationPage({
    super.key,
    required this.request,
    required this.appDir,
    required this.binaryProvider,
    required this.log,
  });

  @override
  State<ResetConfirmationPage> createState() => _ResetConfirmationPageState();
}

class _ResetConfirmationPageState extends State<ResetConfirmationPage> {
  // Gather state
  bool _gathering = true;
  String? _gatherError;
  List<DeleteItem> _items = [];

  // Deletion state
  bool _isDeleting = false;
  bool _deletionComplete = false;
  bool _stoppingBinaries = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _gather();
  }

  Future<void> _gather() async {
    try {
      final resp = await GetIt.I.get<OrchestratorRPC>().gatherFilesToDelete(widget.request);
      if (!mounted) return;
      setState(() {
        _items = resp.files
            .map((f) => DeleteItem(path: f.path, isWallet: f.deletionType == DeletionType.DELETION_TYPE_WALLET))
            .toList();
        _gathering = false;
      });
    } catch (e) {
      widget.log.e('Could not gather reset files: $e');
      if (!mounted) return;
      setState(() {
        _gatherError = e.toString();
        _gathering = false;
      });
    }
  }

  Future<void> _startDeletion() async {
    setState(() {
      _isDeleting = true;
      _stoppingBinaries = true;
    });

    final pathToItem = {for (final item in _items) item.path: item};

    try {
      await for (final event in GetIt.I.get<OrchestratorRPC>().deleteFiles(widget.request)) {
        if (!mounted) return;
        setState(() {
          _stoppingBinaries = false;
          final item = pathToItem[event.path];
          if (item != null) {
            _currentIndex = _items.indexOf(item);
            item.status = event.error.isEmpty ? DeleteItemStatus.success : DeleteItemStatus.error;
            if (event.error.isNotEmpty) item.errorMessage = event.error;
          }
        });
      }
    } catch (e) {
      widget.log.e('Reset delete stream failed: $e');
      if (mounted) {
        setState(() {
          for (final item in _items) {
            if (item.status == DeleteItemStatus.pending || item.status == DeleteItemStatus.inProgress) {
              item.status = DeleteItemStatus.error;
              item.errorMessage = e.toString();
            }
          }
        });
      }
    }

    // Any path the server didn't report on shouldn't linger grey forever.
    if (mounted) {
      setState(() {
        for (final item in _items) {
          if (item.status == DeleteItemStatus.pending || item.status == DeleteItemStatus.inProgress) {
            item.status = DeleteItemStatus.error;
            item.errorMessage = 'No result from orchestrator';
          }
        }
      });
    }

    if (mounted) {
      setState(() => _deletionComplete = true);
    }
  }

  void _handleBack() {
    // Return true if deletion happened, so caller knows to restart binaries.
    Navigator.of(context).pop(_isDeleting);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final successCount = _items.where((f) => f.status == DeleteItemStatus.success).length;
    final errorCount = _items.where((f) => f.status == DeleteItemStatus.error).length;
    final hasMovedItems = _items.any((f) => f.isWallet);
    final resetVerb = hasMovedItems ? 'deleted or moved' : 'deleted';

    return PopScope(
      // Prevent back during active deletion, allow after completion
      canPop: !_isDeleting || _deletionComplete,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _deletionComplete) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          foregroundColor: theme.colors.text,
          leading: SailAppBarBackButton(
            onPressed: _isDeleting && !_deletionComplete ? null : _handleBack,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: 800,
                child: _gathering
                    ? Center(
                        child: SailRow(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: SailStyleValues.padding08,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: theme.colors.primary),
                            ),
                            SailText.secondary13('Gathering files...'),
                          ],
                        ),
                      )
                    : _gatherError != null
                    ? Center(child: SailText.secondary13('Could not compute reset preview: $_gatherError'))
                    : _items.isEmpty
                    ? Center(child: SailText.secondary13('Nothing to delete.'))
                    : _buildContent(theme, successCount, errorCount, hasMovedItems, resetVerb),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    SailThemeData theme,
    int successCount,
    int errorCount,
    bool hasMovedItems,
    String resetVerb,
  ) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              SailRow(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: SailStyleValues.padding12,
                children: [
                  switch (resetHeaderState(deletionComplete: _deletionComplete, errorCount: errorCount)) {
                    ResetHeaderState.success => Icon(Icons.check_circle, color: theme.colors.success, size: 32),
                    ResetHeaderState.partial => SailSVG.fromAsset(
                      SailSVGAsset.iconWarning,
                      color: theme.colors.orange,
                      width: 32,
                      height: 32,
                    ),
                    ResetHeaderState.confirm => SailSVG.fromAsset(
                      SailSVGAsset.iconWarning,
                      color: theme.colors.error,
                      width: 32,
                      height: 32,
                    ),
                  },
                  SailText.primary24(
                    switch (resetHeaderState(deletionComplete: _deletionComplete, errorCount: errorCount)) {
                      ResetHeaderState.success => 'Reset Complete',
                      ResetHeaderState.partial => 'Reset Partially Complete',
                      ResetHeaderState.confirm => 'Confirm Deletion',
                    },
                    bold: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isDeleting && !_deletionComplete) ...[
                if (_stoppingBinaries)
                  SailRow(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: SailStyleValues.padding08,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.colors.primary),
                      ),
                      SailText.secondary13('Stopping binaries...'),
                    ],
                  )
                else
                  SailText.secondary13('Deleting: ${_currentIndex + 1} / ${_items.length}'),
              ] else if (_deletionComplete)
                SailText.secondary13(
                  '${hasMovedItems ? 'Reset' : 'Deleted'} $successCount items${errorCount > 0 ? ', $errorCount failed' : ''}',
                )
              else
                SailText.secondary13('The following ${_items.length} items will be $resetVerb:'),
              const SizedBox(height: 24),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.backgroundSecondary,
                  borderRadius: SailStyleValues.borderRadiusSmall,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding12),
                  child: _isDeleting
                      ? _DeletionProgress(filesToDelete: _items)
                      : PathTreeView(paths: _items.map((f) => f.path).toList()),
                ),
              ),
            ],
          ),
        ),
        BottomActionBar(
          children: [
            if (!_isDeleting) ...[
              SailButton(
                label: 'Cancel',
                onPressed: () async => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: SailStyleValues.padding12),
              SailButton(
                label: hasMovedItems ? 'Reset ${_items.length} items' : 'Delete ${_items.length} items',
                variant: ButtonVariant.destructive,
                onPressed: () async => await _startDeletion(),
              ),
            ] else if (_deletionComplete)
              SailButton(
                label: 'Continue',
                variant: ButtonVariant.primary,
                onPressed: () async => _handleBack(),
              ),
          ],
        ),
      ],
    );
  }
}

class _DeletionProgress extends StatelessWidget {
  final List<DeleteItem> filesToDelete;

  const _DeletionProgress({required this.filesToDelete});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filesToDelete.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              _StatusIcon(status: item.status),
              Expanded(
                child: SailText.secondary12(
                  item.path,
                  monospace: true,
                  color: item.status == DeleteItemStatus.error ? theme.colors.error : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final DeleteItemStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    switch (status) {
      case DeleteItemStatus.pending:
        return SizedBox(
          width: 16,
          height: 16,
          child: Icon(Icons.circle_outlined, size: 14, color: theme.colors.textTertiary),
        );
      case DeleteItemStatus.inProgress:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.colors.primary),
        );
      case DeleteItemStatus.success:
        return SizedBox(
          width: 16,
          height: 16,
          child: Icon(Icons.check_circle, size: 16, color: theme.colors.success),
        );
      case DeleteItemStatus.error:
        return SizedBox(
          width: 16,
          height: 16,
          child: Icon(Icons.error, size: 16, color: theme.colors.error),
        );
    }
  }
}
