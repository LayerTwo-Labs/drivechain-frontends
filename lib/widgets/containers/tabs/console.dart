import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';

class RPCWidget extends StatefulWidget {
  const RPCWidget({super.key});

  @override
  RPCWidgetState createState() => RPCWidgetState();
}

class RPCWidgetState extends State<RPCWidget> {
  EthereumRPC get rpc => GetIt.I.get<EthereumRPC>();
  dynamic _result;
  String _command = '';
  String? _error;

  Future<dynamic> _callRpc(String args) async {
    if (args.trim().isEmpty) {
      throw 'Must provide method name';
    }

    final fields = args.trim().split(' ').where((field) => field.isNotEmpty);

    final start = DateTime.now();

    List<String> params = [];
    if (fields.length > 1) {
      params = fields.skip(1).toList();
    }

    final method = fields.first;
    var res = await rpc.callRAW(method, params);

    log.t(
      'eth: $method completed in ${DateTime.now().difference(start)}',
      error: jsonEncode(res),
    );

    return res;
  }

  void _handleSubmit(String selection) async {
    try {
      var res = await _callRpc(selection);

      setState(() {
        _command = selection;
        _result = res;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _command = selection;
        _result = null;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return ethRpcMethods.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                optionsMaxHeight: 500,
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return SailTextField(
                    controller: textEditingController,
                    label: 'RPC command',
                    prefix: '> ',
                    hintText: 'Enter rpc command here',
                    focusNode: focusNode,
                    onSubmitted: _handleSubmit,
                    suffixWidget: SailTextButton(
                      label: 'Submit',
                      onPressed: () {
                        _handleSubmit(textEditingController.text);
                      },
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Scaffold(
                    backgroundColor: theme.colors.background,
                    body: Padding(
                      padding: const EdgeInsets.only(left: SailStyleValues.padding30),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SailColumn(
                          spacing: SailStyleValues.padding08,
                          withDivider: true,
                          children: [
                            for (final opt in options)
                              SailScaleButton(
                                onPressed: () => onSelected(opt),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SailStyleValues.padding10,
                                    horizontal: SailStyleValues.padding10,
                                  ),
                                  child: SailText.primary12(opt),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (String selection) {
                  _handleSubmit(selection);
                },
              ),
            ),
          ],
        ),
        if (_result != null) _JSONView(_result),
        if (_error != null) _ErrorView('$_command: $_error'),
      ],
    );
  }
}

class _JSONView extends StatelessWidget {
  final dynamic json;

  const _JSONView(this.json);

  String prettyPrintJson(dynamic json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    var printed = encoder.convert(json);
    return printed;
  }

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      padding: true,
      child: SailColumn(
        spacing: SailStyleValues.padding50,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding08,
            withDivider: true,
            trailingSpacing: true,
            children: [
              const ActionHeaderChip(title: 'Response'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SailStyleValues.padding10,
                ),
                child: SailText.primary12(json.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView(this.error);

  @override
  Widget build(BuildContext context) {
    return SailRawCard(
      padding: true,
      child: SailColumn(
        spacing: SailStyleValues.padding50,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding08,
            withDivider: true,
            trailingSpacing: true,
            children: [
              const SailErrorShadow(
                enabled: true,
                small: true,
                child: ActionHeaderChip(title: 'Error'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SailStyleValues.padding10,
                ),
                child: SailText.primary12(error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
