import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class TextSettingRow extends StatefulWidget {
  final String label;
  final String value;
  final String? hintText;
  final ValueChanged<String> onChanged;

  const TextSettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<TextSettingRow> createState() => _TextSettingRowState();
}

class _TextSettingRowState extends State<TextSettingRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(TextSettingRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(widget.label),
          const SailSpacing(SailStyleValues.padding04),
          SailTextField(
            controller: _controller,
            hintText: widget.hintText ?? widget.label,
            onSubmitted: widget.onChanged,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class DropdownSettingRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const DropdownSettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary12(label),
          const SailSpacing(SailStyleValues.padding04),
          SailDropdownButton<String>(
            value: value,
            items: options.map((opt) => SailDropdownItem<String>(value: opt, label: opt)).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class ToggleSettingRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary12(label),
          SailToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
