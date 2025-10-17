import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class BitcoinURIDialog extends StatefulWidget {
  const BitcoinURIDialog({super.key});

  @override
  State<BitcoinURIDialog> createState() => _BitcoinURIDialogState();
}

class _BitcoinURIDialogState extends State<BitcoinURIDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  BitcoinURI? _parsedURI;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_parseURI);
  }

  void _parseURI() {
    try {
      setState(() {
        _parsedURI = BitcoinURI.parse(_controller.text);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _parsedURI = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_parseURI);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailDialog(
      title: 'Open Bitcoin URI',
      subtitle: 'Enter a Bitcoin URI to parse',
      error: _error,
      maxWidth: 400,
      maxHeight: 600,
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding16,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailTextField(
            label: 'Bitcoin URI',
            controller: _controller,
            hintText: 'bitcoin:<address>?amount=1.23',
          ),
          if (_parsedURI != null) ...[
            SailText.primary13('Address: ${_parsedURI!.address}'),
            if (_parsedURI!.amount != null) SailText.primary13('Amount: ${_parsedURI!.amount} BTC'),
            if (_parsedURI!.label != null) SailText.primary13('Label: ${_parsedURI!.label}'),
            if (_parsedURI!.message != null) SailText.primary13('Message: ${_parsedURI!.message}'),
          ],
          SailButton(
            label: 'Use',
            onPressed: () async {
              if (_parsedURI != null) {
                Navigator.of(context).pop(_parsedURI);
              }
            },
            disabled: _parsedURI == null,
          ),
        ],
      ),
    );
  }
}
