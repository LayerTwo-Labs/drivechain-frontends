import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class NumericField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String label;
  final Function(String)? onEditingComplete;
  final Function(String)? onSubmitted;
  final String hintText;
  final bool enabled;
  final String? error;
  final Widget? suffixWidget;
  final List<TextInputFormatter>? inputFormatters;

  const NumericField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.hintText = '0.00',
    this.enabled = true,
    this.error = '',
    this.suffixWidget,
    this.inputFormatters,
  });

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  late TextEditingController _controller = TextEditingController(text: '0.00');
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController(text: '0.00');
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return SailTextField(
      label: widget.label,
      controller: _controller,
      hintText: widget.hintText,
      focusNode: _focusNode,
      textFieldType: TextFieldType.bitcoin,
      size: TextFieldSize.small,
      enabled: widget.enabled,
      suffixWidget: widget.suffixWidget,
      onSubmitted: widget.onSubmitted != null ? (value) => widget.onSubmitted!(value) : null,
      inputFormatters: widget.inputFormatters,
    );
  }
}
