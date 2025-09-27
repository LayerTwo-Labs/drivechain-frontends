import 'package:bitwindow/viewmodels/bitcoin_config_editor_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class WorkingConfigPanel extends ViewModelWidget<BitcoinConfigEditorViewModel> {
  const WorkingConfigPanel({super.key});

  @override
  Widget build(BuildContext context, BitcoinConfigEditorViewModel viewModel) {
    return _WorkingConfigPanelContent(viewModel: viewModel);
  }
}

class _WorkingConfigPanelContent extends StatefulWidget {
  final BitcoinConfigEditorViewModel viewModel;

  const _WorkingConfigPanelContent({required this.viewModel});

  @override
  State<_WorkingConfigPanelContent> createState() => _WorkingConfigPanelContentState();
}

class _WorkingConfigPanelContentState extends State<_WorkingConfigPanelContent> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    widget.viewModel.addListener(_onConfigChanged);
    _updateTextController();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onConfigChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) {
      _updateTextController();
      setState(() {});
    }
  }

  void _updateTextController() {
    final newText = widget.viewModel.workingConfigText;
    if (_textController.text != newText) {
      _textController.text = newText;
    }
  }

  void _onTextChanged(String value) {
    widget.viewModel.updateFromRawText(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SailText.secondary13(
                  'Your Changes',
                  bold: true,
                ),
                const Spacer(),
                SailText.secondary12(
                  widget.viewModel.hasUnsavedChanges ? '• Modified' : '• Saved',
                  color: widget.viewModel.hasUnsavedChanges ? theme.colors.orange : theme.colors.success,
                ),
              ],
            ),
          ),

          Container(
            height: 1,
            color: theme.colors.divider,
          ),

          // Config content
          Expanded(
            child: widget.viewModel.workingConfig == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 12,
                        color: theme.colors.text,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Edit your Bitcoin configuration here...',
                        hintStyle: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 12,
                          color: theme.colors.textTertiary,
                          height: 1.4,
                        ),
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
