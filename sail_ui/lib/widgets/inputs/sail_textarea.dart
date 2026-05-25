import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailTextarea extends StatefulWidget {
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String placeholder;
  final String? label;
  final String? helperText;
  final int minLines;
  final int? maxLines;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const SailTextarea({
    super.key,
    this.controller,
    this.value,
    this.onChanged,
    this.onSubmitted,
    this.placeholder = '',
    this.label,
    this.helperText,
    this.minLines = 3,
    this.maxLines,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.inputFormatters,
  }) : assert(
         controller == null || value == null,
         'Provide either controller or value, not both',
       );

  @override
  State<SailTextarea> createState() => _SailTextareaState();
}

class _SailTextareaState extends State<SailTextarea> {
  TextEditingController? _internal;

  TextEditingController get _effective {
    if (widget.controller != null) return widget.controller!;
    return _internal ??= TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant SailTextarea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.value != null && _internal != null && _internal!.text != widget.value) {
      _internal!.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailTextField(
      controller: _effective,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      label: widget.label,
      hintText: widget.placeholder,
      helperText: widget.helperText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
    );
  }
}
