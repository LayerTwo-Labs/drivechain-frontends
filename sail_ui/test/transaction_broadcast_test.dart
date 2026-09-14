import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/pages/sidechains/explorer/transaction_broadcast.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;

const _txid = '48b4eed66e27c813e1d0f78746c2706da309b673b42a18d03fe50ab3524aecae';
const _signedTransaction = ' { "transaction": {"inputs": [], "outputs": []}, "authorizations": [] }\n';

class _ExplorerModel extends Fake implements ExplorerModel {
  @override
  final String chain;

  final List<String> copiedIds = [];
  final List<String> rebroadcastIds = [];
  final List<String> broadcastPayloads = [];
  int peerCount = 2;
  Object? copyError;
  Object? rebroadcastError;
  Object? broadcastError;
  Completer<String>? copyReply;
  Completer<pb.RebroadcastTransactionResponse>? rebroadcastReply;
  Completer<pb.BroadcastTransactionResponse>? broadcastReply;

  _ExplorerModel({this.chain = 'bitnames'});

  @override
  Future<pb.Transaction> transaction(String txid) async {
    return pb.Transaction(txid: txid, kind: pb.Kind.KIND_TRANSFER);
  }

  @override
  Future<String> signedTransaction(String txid) async {
    copiedIds.add(txid);
    if (copyError != null) {
      throw copyError!;
    }
    return copyReply?.future ?? _signedTransaction;
  }

  @override
  Future<pb.RebroadcastTransactionResponse> rebroadcastTransaction(String txid) async {
    rebroadcastIds.add(txid);
    if (rebroadcastError != null) {
      throw rebroadcastError!;
    }
    return rebroadcastReply?.future ?? pb.RebroadcastTransactionResponse(txid: txid, peerCount: peerCount);
  }

  @override
  Future<pb.BroadcastTransactionResponse> broadcastTransaction(String signedTransaction) async {
    broadcastPayloads.add(signedTransaction);
    if (broadcastError != null) {
      throw broadcastError!;
    }
    return broadcastReply?.future ?? pb.BroadcastTransactionResponse(txid: _txid, peerCount: peerCount);
  }
}

Widget _app(Widget child) {
  return MaterialApp(
    builder: (context, child) =>
        SailTheme(data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter), child: child!),
    home: Scaffold(body: child),
  );
}

Future<void> _showActions(
  WidgetTester tester,
  _ExplorerModel model, {
  bool confirmed = false,
  pb.Kind kind = pb.Kind.KIND_TRANSFER,
  ValueChanged<ExplorerTarget>? onOpen,
}) async {
  await tester.pumpWidget(
    _app(
      ExplorerTransactionActions(
        model: model,
        transaction: pb.Transaction(txid: _txid, confirmed: confirmed, kind: kind),
        onOpen: onOpen ?? (_) {},
      ),
    ),
  );
}

Future<void> _showForm(WidgetTester tester, _ExplorerModel model, {ValueChanged<ExplorerTarget>? onOpen}) async {
  await tester.pumpWidget(_app(ExplorerBroadcastButton(model: model, onOpen: onOpen ?? (_) {})));
  await tester.tap(_button('Broadcast Transaction'));
  await tester.pumpAndSettle();
}

Finder _button(String label) => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == label);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  for (final chain in ['bitnames', 'bitassets']) {
    testWidgets('$chain shows both actions for a pending transaction', (tester) async {
      await _showActions(tester, _ExplorerModel(chain: chain));

      expect(_button('Rebroadcast'), findsOneWidget);
      expect(_button('Copy Signed Transaction'), findsOneWidget);
    });

    testWidgets('$chain opens the signed transaction form', (tester) async {
      await _showForm(tester, _ExplorerModel(chain: chain));

      expect(find.byType(SailTextarea), findsOneWidget);
      expect(find.text('Paste the full signed transaction JSON for $chain.'), findsOneWidget);
    });
  }

  testWidgets('included transactions show no actions', (tester) async {
    await _showActions(tester, _ExplorerModel(), confirmed: true);

    expect(find.byType(SailButton), findsNothing);
  });

  testWidgets('deposits show no actions', (tester) async {
    await _showActions(tester, _ExplorerModel(), kind: pb.Kind.KIND_DEPOSIT);

    expect(find.byType(SailButton), findsNothing);
  });

  testWidgets('unsupported chains show no broadcast controls', (tester) async {
    for (final chain in ['thunder', 'zside', 'coinshift', 'bbc', 'liquid-signet']) {
      final model = _ExplorerModel(chain: chain);
      await _showActions(tester, model);
      expect(find.byType(SailButton), findsNothing);

      await tester.pumpWidget(_app(ExplorerBroadcastButton(model: model, onOpen: (_) {})));
      expect(find.byType(SailButton), findsNothing);
    }
  });

  testWidgets('rebroadcast uses the same ID and opens the returned transaction', (tester) async {
    final model = _ExplorerModel();
    ExplorerTarget? target;
    await _showActions(tester, model, onOpen: (value) => target = value);

    await tester.tap(_button('Rebroadcast'));
    await tester.pumpAndSettle();

    expect(model.rebroadcastIds, [_txid]);
    expect(model.broadcastPayloads, isEmpty);
    expect(find.text(_txid), findsOneWidget);
    expect(find.text('The node accepted the transaction.'), findsOneWidget);
    expect(find.text('The transaction remains pending until a block includes it.'), findsOneWidget);

    await tester.tap(_button('Open Transaction'));
    await tester.pumpAndSettle();
    expect(target?.id, _txid);
    expect(target?.kind, ExplorerTargetKind.transaction);
  });

  testWidgets('rebroadcast reports zero peers', (tester) async {
    final model = _ExplorerModel()..peerCount = 0;
    await _showActions(tester, model);

    await tester.tap(_button('Rebroadcast'));
    await tester.pumpAndSettle();

    expect(find.text('No peers are connected. The node will retry.'), findsOneWidget);
  });

  testWidgets('a late rebroadcast response does not change another transaction', (tester) async {
    final reply = Completer<pb.RebroadcastTransactionResponse>();
    final model = _ExplorerModel()..rebroadcastReply = reply;
    final target = ValueNotifier(ExplorerTarget.transaction(_txid));
    addTearDown(target.dispose);
    await tester.pumpWidget(
      _app(
        SingleChildScrollView(
          child: ValueListenableBuilder<ExplorerTarget>(
            valueListenable: target,
            builder: (context, value, child) => ExplorerDetail(
              model: model,
              target: value,
              onClose: () {},
              onOpen: (value) => target.value = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_button('Rebroadcast'));
    await tester.pump();

    const nextId = '58b4eed66e27c813e1d0f78746c2706da309b673b42a18d03fe50ab3524aecae';
    target.value = ExplorerTarget.transaction(nextId);
    await tester.pumpAndSettle();
    expect(find.text(nextId), findsOneWidget);
    expect(tester.widget<SailButton>(_button('Rebroadcast')).disabled, isFalse);

    reply.complete(pb.RebroadcastTransactionResponse(txid: _txid, peerCount: 1));
    await tester.pumpAndSettle();
    expect(find.text(_txid), findsNothing);
    expect(find.text('The node accepted the transaction.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the pending actions fit a narrow desktop panel', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 660));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _showActions(tester, _ExplorerModel());
    await tester.tap(_button('Rebroadcast'));
    await tester.pumpAndSettle();

    expect(_button('Copy Signed Transaction').hitTestable(), findsOneWidget);
    expect(_button('Open Transaction').hitTestable(), findsOneWidget);
    expect(tester.renderObject<RenderParagraph>(find.text(_txid)).didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rebroadcast errors stay visible and permit a retry', (tester) async {
    final model = _ExplorerModel()..rebroadcastError = StateError('The node rejected the transaction.');
    await _showActions(tester, model);

    await tester.tap(_button('Rebroadcast'));
    await tester.pumpAndSettle();
    expect(find.textContaining('The node rejected the transaction.'), findsOneWidget);
    expect(find.text('The node accepted the transaction.'), findsNothing);

    model.rebroadcastError = null;
    await tester.tap(_button('Rebroadcast'));
    await tester.pumpAndSettle();
    expect(model.rebroadcastIds, [_txid, _txid]);
    expect(find.textContaining('The node rejected the transaction.'), findsNothing);
    expect(find.text('The node accepted the transaction.'), findsOneWidget);
  });

  testWidgets('rebroadcast blocks repeated clicks and copy until the response arrives', (tester) async {
    final reply = Completer<pb.RebroadcastTransactionResponse>();
    final model = _ExplorerModel()..rebroadcastReply = reply;
    await _showActions(tester, model);

    await tester.tap(_button('Rebroadcast'));
    await tester.pump();
    expect(tester.widget<SailButton>(_button('Rebroadcast')).disabled, isTrue);
    expect(tester.widget<SailButton>(_button('Copy Signed Transaction')).disabled, isTrue);
    await tester.tap(_button('Rebroadcast'));
    await tester.tap(_button('Copy Signed Transaction'));
    expect(model.rebroadcastIds, [_txid]);
    expect(model.copiedIds, isEmpty);

    reply.complete(pb.RebroadcastTransactionResponse(txid: _txid, peerCount: 1));
    await tester.pumpAndSettle();
    expect(tester.widget<SailButton>(_button('Rebroadcast')).disabled, isFalse);
  });

  testWidgets('copy keeps the signed transaction text unchanged', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final model = _ExplorerModel();
    await _showActions(tester, model);

    await tester.tap(_button('Copy Signed Transaction'));
    await tester.pumpAndSettle();

    expect(model.copiedIds, [_txid]);
    expect(clipboard, _signedTransaction);
    expect(find.text('The signed transaction is on the clipboard.'), findsOneWidget);
  });

  testWidgets('copy errors stay visible', (tester) async {
    final model = _ExplorerModel()..copyError = StateError('The transaction is absent from the mempool.');
    await _showActions(tester, model);

    await tester.tap(_button('Copy Signed Transaction'));
    await tester.pumpAndSettle();

    expect(find.textContaining('The transaction is absent from the mempool.'), findsOneWidget);
    expect(find.text('The signed transaction is on the clipboard.'), findsNothing);
  });

  testWidgets('copy blocks repeated clicks and rebroadcast until the response arrives', (tester) async {
    final reply = Completer<String>();
    final model = _ExplorerModel()..copyReply = reply;
    await _showActions(tester, model);

    await tester.tap(_button('Copy Signed Transaction'));
    await tester.pump();
    await tester.tap(_button('Copy Signed Transaction'));
    await tester.tap(_button('Rebroadcast'));
    expect(model.copiedIds, [_txid]);
    expect(model.rebroadcastIds, isEmpty);

    reply.complete(_signedTransaction);
    await tester.pumpAndSettle();
  });

  testWidgets('the form rejects empty text', (tester) async {
    final model = _ExplorerModel();
    await _showForm(tester, model);

    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();

    expect(find.text('Paste a signed transaction.'), findsOneWidget);
    expect(model.broadcastPayloads, isEmpty);
  });

  testWidgets('the form fits a narrow desktop panel', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 660));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _showForm(tester, _ExplorerModel());
    await tester.enterText(find.byType(TextField), _signedTransaction);
    await tester.pumpAndSettle();

    expect(_button('Broadcast').hitTestable(), findsOneWidget);
    expect(_button('Close').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the form rejects malformed JSON', (tester) async {
    final model = _ExplorerModel();
    await _showForm(tester, model);
    await tester.enterText(find.byType(TextField), '{');

    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();

    expect(find.text('The signed transaction contains invalid JSON.'), findsOneWidget);
    expect(model.broadcastPayloads, isEmpty);
  });

  testWidgets('the form rejects JSON that is not an object', (tester) async {
    final model = _ExplorerModel();
    await _showForm(tester, model);
    await tester.enterText(find.byType(TextField), '[]');

    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();

    expect(find.text('The signed transaction must be a JSON object.'), findsOneWidget);
    expect(model.broadcastPayloads, isEmpty);
  });

  testWidgets('the form keeps the payload unchanged and opens the returned transaction', (tester) async {
    final model = _ExplorerModel();
    ExplorerTarget? target;
    await _showForm(tester, model, onOpen: (value) => target = value);
    await tester.enterText(find.byType(TextField), _signedTransaction);

    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();

    expect(model.broadcastPayloads, [_signedTransaction]);
    expect(model.rebroadcastIds, isEmpty);
    expect(find.text(_txid), findsOneWidget);
    expect(find.text('The node accepted the transaction.'), findsOneWidget);
    expect(_button('Broadcast'), findsNothing);

    await tester.tap(_button('Open Transaction'));
    await tester.pumpAndSettle();
    expect(target?.id, _txid);
    expect(target?.kind, ExplorerTargetKind.transaction);
    expect(find.byType(SailDialog), findsNothing);
  });

  testWidgets('the form reports zero peers', (tester) async {
    final model = _ExplorerModel()..peerCount = 0;
    await _showForm(tester, model);
    await tester.enterText(find.byType(TextField), _signedTransaction);

    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();

    expect(find.text('No peers are connected. The node will retry.'), findsOneWidget);
  });

  testWidgets('the form keeps the payload and error after node rejection', (tester) async {
    final model = _ExplorerModel()..broadcastError = StateError('The signature is invalid.');
    await _showForm(tester, model);
    await tester.enterText(find.byType(TextField), _signedTransaction);

    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();

    expect(find.textContaining('The signature is invalid.'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, _signedTransaction);
    expect(find.text('The node accepted the transaction.'), findsNothing);

    model.broadcastError = null;
    await tester.tap(_button('Broadcast'));
    await tester.pumpAndSettle();
    expect(model.broadcastPayloads, [_signedTransaction, _signedTransaction]);
    expect(find.textContaining('The signature is invalid.'), findsNothing);
    expect(find.text('The node accepted the transaction.'), findsOneWidget);
  });

  testWidgets('the form blocks repeated clicks and edits until the response arrives', (tester) async {
    final reply = Completer<pb.BroadcastTransactionResponse>();
    final model = _ExplorerModel()..broadcastReply = reply;
    await _showForm(tester, model);
    await tester.enterText(find.byType(TextField), _signedTransaction);

    await tester.tap(_button('Broadcast'));
    await tester.pump();
    expect(tester.widget<SailButton>(_button('Broadcast')).disabled, isTrue);
    expect(tester.widget<SailButton>(_button('Close')).disabled, isTrue);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await tester.tap(_button('Broadcast'));
    await tester.tap(_button('Close'));
    expect(model.broadcastPayloads, [_signedTransaction]);
    expect(find.byType(SailDialog), findsOneWidget);

    reply.complete(pb.BroadcastTransactionResponse(txid: _txid, peerCount: 1));
    await tester.pumpAndSettle();
    expect(tester.widget<SailButton>(_button('Close')).disabled, isFalse);
  });
}
