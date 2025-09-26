import 'package:bitwindow/providers/bitcoin_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sail_ui/sail_ui.dart';

class WorkingConfigPanel extends StatefulWidget {
  const WorkingConfigPanel({super.key});

  @override
  State<WorkingConfigPanel> createState() => _WorkingConfigPanelState();
}

class _WorkingConfigPanelState extends State<WorkingConfigPanel> {
  late final BitcoinConfigProvider _configProvider;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _configProvider = GetIt.I.get<BitcoinConfigProvider>();
    _textController = TextEditingController();
    _configProvider.addListener(_onConfigChanged);
    _updateTextController();
  }

  @override
  void dispose() {
    _configProvider.removeListener(_onConfigChanged);
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
    final newText = _configProvider.workingConfigText;
    if (_textController.text != newText) {
      _textController.text = newText;
    }
  }

  void _onTextChanged(String value) {
    _configProvider.updateFromRawText(value);
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
                  _configProvider.hasUnsavedChanges ? '• Modified' : '• Saved',
                  color: _configProvider.hasUnsavedChanges ? theme.colors.orange : theme.colors.success,
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
            child: _configProvider.workingConfig == null
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
                      style: GoogleFonts.sourceCodePro(
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
                        hintStyle: GoogleFonts.sourceCodePro(
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
