import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Page showing files that will be deleted and asking for confirmation
class ResetConfirmationPage extends StatefulWidget {
  final List<DeleteItem> filesToDelete;
  final List<Binary> binariesToReset;
  final Directory appDir;
  final BinaryProvider binaryProvider;
  final bool deleteNodeSoftware;
  final Logger log;

  const ResetConfirmationPage({
    super.key,
    required this.filesToDelete,
    required this.binariesToReset,
    required this.appDir,
    required this.binaryProvider,
    required this.deleteNodeSoftware,
    required this.log,
  });

  @override
  State<ResetConfirmationPage> createState() => _ResetConfirmationPageState();
}

class _ResetConfirmationPageState extends State<ResetConfirmationPage> {
  bool _showUntouched = false;
  List<String>? _untouchedFiles;
  bool _loadingUntouched = false;

  // Deletion state
  bool _isDeleting = false;
  bool _deletionComplete = false;
  bool _stoppingBinaries = false;
  int _currentIndex = 0;

  Future<void> _loadUntouchedFiles() async {
    if (_untouchedFiles != null) return;

    setState(() => _loadingUntouched = true);

    final allDatadirPaths = <String>{};
    final filesToDeletePaths = widget.filesToDelete.map((f) => f.path).toSet();

    for (final binary in widget.binariesToReset) {
      final paths = await binary.getAllDatadirPaths();
      allDatadirPaths.addAll(paths);
    }

    for (final binary in widget.binariesToReset) {
      final binPaths = await binary.getBinaryPaths(binDir(widget.appDir.path));
      for (final binPath in binPaths) {
        if (await FileSystemEntity.isDirectory(binPath)) {
          try {
            await for (final entity in Directory(binPath).list(recursive: true, followLinks: false)) {
              allDatadirPaths.add(entity.path);
            }
          } catch (_) {}
        }
        allDatadirPaths.add(binPath);
      }
    }

    final untouched = allDatadirPaths.where((p) {
      if (filesToDeletePaths.contains(p)) return false;
      for (final deletePath in filesToDeletePaths) {
        if (p.startsWith('$deletePath${Platform.pathSeparator}')) return false;
      }
      return true;
    }).toList()..sort();

    if (mounted) {
      setState(() {
        _untouchedFiles = untouched;
        _loadingUntouched = false;
      });
    }
  }

  Future<void> _startDeletion() async {
    setState(() {
      _isDeleting = true;
      _stoppingBinaries = true;
    });

    // Stop binaries first
    await Future.wait(widget.binariesToReset.map((b) => widget.binaryProvider.stop(b)));
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _stoppingBinaries = false);

    // Delete each file one by one
    for (var i = 0; i < widget.filesToDelete.length; i++) {
      if (!mounted) return;

      final item = widget.filesToDelete[i];
      setState(() {
        _currentIndex = i;
        item.status = DeleteItemStatus.inProgress;
      });

      try {
        final filePath = item.path;
        if (await FileSystemEntity.isDirectory(filePath)) {
          await Directory(filePath).delete(recursive: true);
        } else {
          final f = File(filePath);
          if (await f.exists()) {
            await f.delete();
          }
        }
        if (mounted) {
          setState(() => item.status = DeleteItemStatus.success);
        }
      } catch (e) {
        widget.log.e('Failed to delete ${item.path}: $e');
        if (mounted) {
          setState(() {
            item.status = DeleteItemStatus.error;
            item.errorMessage = e.toString();
          });
        }
      }

      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Re-download binaries if needed
    if (widget.deleteNodeSoftware) {
      await copyBinariesFromAssets(widget.log, widget.appDir);
    }

    if (mounted) {
      setState(() => _deletionComplete = true);
    }
  }

  void _handleBack() {
    // Return true if deletion happened, so caller knows to restart binaries
    Navigator.of(context).pop(_isDeleting);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final successCount = widget.filesToDelete.where((f) => f.status == DeleteItemStatus.success).length;
    final errorCount = widget.filesToDelete.where((f) => f.status == DeleteItemStatus.error).length;

    return PopScope(
      // Prevent back during active deletion, allow after completion
      canPop: !_isDeleting || _deletionComplete,
      onPopInvokedWithResult: (didPop, result) {
        // If pop was prevented and deletion is complete, manually pop with result
        if (!didPop && _deletionComplete) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          foregroundColor: theme.colors.text,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isDeleting && !_deletionComplete ? null : _handleBack,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: 800,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          SailRow(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: SailStyleValues.padding12,
                            children: [
                              if (_deletionComplete)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colors.success,
                                  size: 32,
                                )
                              else
                                SailSVG.fromAsset(
                                  SailSVGAsset.iconWarning,
                                  color: theme.colors.error,
                                  width: 32,
                                  height: 32,
                                ),
                              SailText.primary24(
                                _deletionComplete ? 'Reset Complete' : 'Confirm Deletion',
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colors.primary,
                                    ),
                                  ),
                                  SailText.secondary13('Stopping binaries...'),
                                ],
                              )
                            else
                              SailText.secondary13(
                                'Deleting: ${_currentIndex + 1} / ${widget.filesToDelete.length}',
                              ),
                          ] else if (_deletionComplete)
                            SailText.secondary13(
                              'Deleted $successCount items${errorCount > 0 ? ', $errorCount failed' : ''}',
                            )
                          else
                            SailText.secondary13(
                              'The following ${widget.filesToDelete.length} items will be deleted:',
                            ),
                          const SizedBox(height: 24),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colors.backgroundSecondary,
                              borderRadius: SailStyleValues.borderRadiusSmall,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(SailStyleValues.padding12),
                              child: _isDeleting
                                  ? _buildDeletionProgress(theme)
                                  : PathTreeView(paths: widget.filesToDelete.map((f) => f.path).toList()),
                            ),
                          ),
                          if (!_isDeleting) ...[
                            const SizedBox(height: 24),
                            Center(
                              child: SailButton(
                                label: _showUntouched ? 'Hide untouched files' : 'Show untouched files',
                                variant: ButtonVariant.ghost,
                                onPressed: () async {
                                  if (!_showUntouched) {
                                    await _loadUntouchedFiles();
                                  }
                                  setState(() => _showUntouched = !_showUntouched);
                                },
                              ),
                            ),
                            if (_showUntouched) ...[
                              const SizedBox(height: 24),
                              if (_loadingUntouched)
                                Center(
                                  child: SailRow(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: SailStyleValues.padding12,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colors.primary,
                                        ),
                                      ),
                                      SailText.secondary12('Loading...'),
                                    ],
                                  ),
                                )
                              else if (_untouchedFiles != null && _untouchedFiles!.isNotEmpty) ...[
                                SailText.secondary13(
                                  '${_untouchedFiles!.length} files will NOT be deleted:',
                                ),
                                const SizedBox(height: 12),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme.colors.backgroundSecondary,
                                    borderRadius: SailStyleValues.borderRadiusSmall,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(SailStyleValues.padding12),
                                    child: PathTreeView(paths: _untouchedFiles!),
                                  ),
                                ),
                              ] else
                                Center(child: SailText.secondary12('No untouched files found.')),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
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
                      label: 'Delete ${widget.filesToDelete.length} items',
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
          ),
        ),
      ),
    );
  }

  Widget _buildDeletionProgress(SailThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.filesToDelete.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              _buildStatusIcon(theme, item.status),
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

  Widget _buildStatusIcon(SailThemeData theme, DeleteItemStatus status) {
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
