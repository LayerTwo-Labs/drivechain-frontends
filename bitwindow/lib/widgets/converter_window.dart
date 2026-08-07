import 'dart:async';

import 'package:bitwindow/utils/converter.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// One input, every representation of it, updating as you type. Conversion is
/// pure Dart — key material never leaves the process.
class ConverterWindow extends StatefulWidget {
  const ConverterWindow({super.key});

  @override
  State<ConverterWindow> createState() => _ConverterWindowState();
}

class _ConverterWindowState extends State<ConverterWindow> {
  final TextEditingController _input = TextEditingController();
  Timer? _debounce;

  ConverterFormat _format = ConverterFormat.auto;
  ConverterResult _result = const ConverterResult(detected: ConverterFormat.ascii);
  bool _revealPassphrase = false;

  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();

  @override
  void initState() {
    super.initState();
    _input.addListener(_scheduleConvert);
    _conf.addListener(_convert);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _conf.removeListener(_convert);
    _input.dispose();
    super.dispose();
  }

  void _scheduleConvert() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), _convert);
  }

  void _convert() {
    if (!mounted) {
      return;
    }
    setState(() => _result = convert(_input.text, _format, _conf.network));
  }

  bool get _isPassphrase => _format == ConverterFormat.passphrase;

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailCard(
              title: 'Input',
              subtitle: 'Anything Bitcoin-shaped: an address, a key, a hash, or plain text.',
              child: SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailDropdownButton<ConverterFormat>(
                        value: _format,
                        items: ConverterFormat.values
                            .map(
                              (f) => SailDropdownItem<ConverterFormat>(value: f, label: f.label),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _format = value);
                          _convert();
                        },
                      ),
                      if (_format == ConverterFormat.auto && _input.text.isNotEmpty)
                        SailText.secondary12('read as ${_result.detected.label}'),
                    ],
                  ),
                  SailTextField(
                    controller: _input,
                    hintText: 'Paste an address, key, hash or text',
                    obscureText: _isPassphrase && !_revealPassphrase,
                    maxLines: _isPassphrase ? 1 : 3,
                  ),
                  if (_isPassphrase)
                    SailColumn(
                      spacing: SailStyleValues.padding04,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailCheckbox(
                          value: _revealPassphrase,
                          label: 'Show passphrase',
                          onChanged: (value) => setState(() => _revealPassphrase = value),
                        ),
                        SailText.secondary12(
                          'Passphrase-derived keys are swept within seconds of funding. '
                          'This mode is for inspecting keys that are already compromised.',
                        ),
                      ],
                    ),
                  if (_result.error != null) SailText.secondary13(_result.error!),
                ],
              ),
            ),
            _section('Encodings', _result.encodings),
            _section('Hashes', _result.hashes),
            _section('Keys & Addresses', _result.keys),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<ConverterRow> rows) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return SailCard(
      title: title,
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.map(_row).toList(),
      ),
    );
  }

  Widget _row(ConverterRow row) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 200, child: SailText.secondary13(row.label)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SailText.primary13(row.value, monospace: true),
          ),
        ),
        CopyButton(text: row.value),
      ],
    );
  }
}
