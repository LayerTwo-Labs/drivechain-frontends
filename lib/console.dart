import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:sidesail/rpc.dart';

class RpcWidget extends StatefulWidget {
  @override
  _RpcWidgetState createState() => _RpcWidgetState();
}

class _RpcWidgetState extends State<RpcWidget> {
  final TextEditingController _textController = TextEditingController();
  dynamic _result;
  String _command = '';
  String _error = '';

  Future<dynamic> _call_rpc(String method) async {
    var res = await rpc.call(method);

    print('bitcoin core: $method returned ${res.runtimeType}: $res');
    return res;
  }

  void _handleSubmit() async {
    try {
      var res = await _call_rpc(_textController.text);

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

  _JsonViewer(this.json);

  String prettyPrintJson(dynamic json) {
    try {
      print("pretty printing ${json.runtimeType} $json");
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      var printed = encoder.convert(json);
      print("printed it: $printed");
      return printed;
    } catch (e) {
      print(
        "could not pretty print $json: $e",
      );
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HighlightView(
      prettyPrintJson(json),
      language: 'json',
      theme: githubTheme,
      textStyle: TextStyle(fontFamily: 'monospace'),
      padding: EdgeInsets.all(12),
    );
  }
}
