import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc.dart';

class RpcWidget extends StatefulWidget {
  const RpcWidget({super.key});

  @override
  RpcWidgetState createState() => RpcWidgetState();
}

class RpcWidgetState extends State<RpcWidget> {
  final TextEditingController _textController = TextEditingController();
  dynamic _result;
  String _command = '';
  String _error = '';

  Future<dynamic> _callRpc(String method) async {
    final start = DateTime.now();

    var res = await rpc.call(method);

    log.t(
        'bitcoin core: $method completed in ${DateTime.now().difference(start)}',
        error: jsonEncode(res));

    return res;
  }

  void _handleSubmit() async {
    try {
      var res = await _callRpc(_textController.text);

      setState(() {
        _command = _textController.text;
        _result = res;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'RPC:',
              ),
              Expanded(
                  child: TextField(
                controller: _textController,
              )),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
          _result != null
              ? _JsonViewer(_result)
              : Text('Error: $_command: $_error'),
        ],
      ),
    );
  }
}

class _JsonViewer extends StatelessWidget {
  final dynamic json;

  const _JsonViewer(this.json);

  String prettyPrintJson(dynamic json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    var printed = encoder.convert(json);
    return printed;
  }

  @override
  Widget build(BuildContext context) {
    return HighlightView(
      prettyPrintJson(json),
      language: 'json',
      theme: githubTheme,
      textStyle: const TextStyle(fontFamily: 'monospace'),
      padding: const EdgeInsets.all(12),
    );
  }
}
