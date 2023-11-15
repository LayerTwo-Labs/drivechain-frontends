import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';

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

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
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
        DashboardGroup(
          title: 'Responses',
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) => ResultView(
                key: ValueKey<int>(results[index].id),
                result: results[index],
              ),
            ),
          ],
        ),
      ],
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleValueContainer(
            width: 0,
            icon: result.error == null
                ? SailSVG.icon(SailSVGAsset.iconSuccess, width: 13)
                : SailSVG.icon(SailSVGAsset.iconFailed, width: 13),
            copyable: true,
            customCopyValue: result.error ?? result.success,
            value: '> ${result.command}\n${result.error ?? result.success}',
          ),
        ],
      ),
    );
  }
}
