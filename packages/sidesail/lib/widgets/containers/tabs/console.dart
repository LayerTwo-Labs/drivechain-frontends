import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class RPCWidget extends StatefulWidget {
  final List<String> rpcMethods;

  const RPCWidget({
    super.key,
    required this.rpcMethods,
  });

  @override
  RPCWidgetState createState() => RPCWidgetState();
}

class Result {
  late int id;
  final String command;
  final String? success;
  final String? error;

  Result({
    required this.command,
    required this.success,
    required this.error,
  }) {
    id = UniqueKey().hashCode;
  }
}

class RPCWidgetState extends State<RPCWidget> {
  Logger get log => GetIt.I.get<Logger>();
  SidechainContainer get rpc => GetIt.I.get<SidechainContainer>();
  List<Result> results = [];

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
    var res = await rpc.rpc.callRAW(method, params);

    log.t(
      'eth: $method completed in ${DateTime.now().difference(start)}',
      error: jsonEncode(res),
    );

    return res;
  }

  void _handleSubmit(String selection) async {
    try {
      var res = await _callRpc(selection);

      results.insert(
        0,
        Result(
          command: selection,
          success: res.toString(),
          error: null,
        ),
      );
    } catch (e) {
      results.insert(
        0,
        Result(
          command: selection,
          success: null,
          error: e.toString(),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    var screenSize = MediaQuery.of(context).size;

    return SizedBox(
      height: screenSize.height * 0.6,
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          Expanded(
            child: SailBorder(
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                itemCount: results.length,
                itemBuilder: (context, index) => ResultView(
                  key: ValueKey<int>(results[index].id),
                  result: results[index],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return widget.rpcMethods;
                    }
                    return widget.rpcMethods.where((String option) {
                      return option.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  optionsMaxHeight: 500,
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return SailTextField(
                      controller: textEditingController,
                      label: 'RPC command',
                      prefixWidget: SailText.secondary12('> ', color: getCaretColor(results.firstOrNull)),
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
                  onSelected: (String selection) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color? getCaretColor(Result? result) {
    if (result == null) {
      return null;
    }

    if (result.success != null) {
      return SailColorScheme.green;
    }
    return SailColorScheme.red;
  }
}

class ResultView extends StatelessWidget {
  final Result result;

  const ResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConsoleResponse(
            icon: result.error == null
                ? SailSVG.icon(SailSVGAsset.iconSuccess, width: 13)
                : SailSVG.icon(SailSVGAsset.iconFailed, width: 13),
            cmd: result.command,
            response: result.error ?? result.success ?? '',
          ),
        ],
      ),
    );
  }
}

class ConsoleResponse extends StatelessWidget {
  final String cmd;
  final String response;
  final Widget icon;

  const ConsoleResponse({
    super.key,
    required this.cmd,
    required this.response,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: SailStyleValues.padding08,
      children: [
        icon,
        Expanded(
          child: SailColumn(
            spacing: 0,
            children: [
              SailText.primary12('> $cmd', color: SailColorScheme.blue),
              SailScaleButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: response));
                  showSnackBar(context, 'Copied ${copyLabel()}');
                },
                child: SailText.primary12(response),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String copyLabel() {
    final textToShow = response;
    if (textToShow.length > 50) {
      return '${textToShow.substring(0, 50)}...';
    }

    return textToShow;
  }
}
