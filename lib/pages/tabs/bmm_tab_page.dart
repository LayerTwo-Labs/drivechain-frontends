import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BlindMergedMiningTabPage extends StatelessWidget {
  const BlindMergedMiningTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'Blind merged mining',
      body: ViewModelBuilder.reactive(
        viewModelBuilder: () => BlindMergedMiningTabPageViewModel(),
        builder: ((context, viewModel, child) {
          return Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SailText.mediumPrimary20('BMM loop'),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: viewModel.running ? null : viewModel.toggleRunning,
                          icon: const Icon(Icons.play_arrow),
                          label: SailText.primary12('Start'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: !viewModel.running ? null : viewModel.toggleRunning,
                          icon: const Icon(Icons.stop),
                          label: SailText.primary12('Stop'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        initialValue: viewModel.bidAmountSats.toString(),
                        readOnly: viewModel.running,
                        inputFormatters: [
                          // just digits
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Bid amount',
                          suffixText: 'sats',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        initialValue: viewModel.refreshSeconds.toString(),
                        readOnly: viewModel.running,
                        inputFormatters: [
                          // just digits
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Refresh',
                          suffixText: 'second(s)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: SingleChildScrollView(
                      child: viewModel.bmmResult != null
                          ? SelectableText(
                              viewModel.bmmResult!,
                            )
                          : const Text('no BMM result yet'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class BlindMergedMiningTabPageViewModel extends BaseViewModel {
  RPC get _rpc => GetIt.I.get<RPC>();

  int bidAmountSats = 1000;
  int refreshSeconds = 1;
  bool running = false;

  String? bmmResult;

  Timer? refreshTimer;

  void toggleRunning() {
    running = !running;
    notifyListeners();

    if (running) {
      log.i('starting refresh timer');

      refreshTimer = Timer.periodic(Duration(seconds: refreshSeconds), (timer) async {
        final res = await _rpc.refreshBMM(bidAmountSats);
        log.i('refresh bmm: $res');

        bmmResult = const JsonEncoder.withIndent('  ').convert(res);
        notifyListeners();
      });
    } else {
      log.i('stopping refresh timer');

      refreshTimer?.cancel();
      refreshTimer = null;
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }
}
