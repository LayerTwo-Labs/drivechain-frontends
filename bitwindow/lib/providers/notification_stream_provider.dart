import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/notification/v1/notification.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class NotificationStreamProvider extends ChangeNotifier {
  final log = GetIt.I.get<Logger>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();
  final BitwindowRPC bitwindow = GetIt.I.get<BitwindowRPC>();

  StreamSubscription<WatchResponse>? _subscription;
  bool isConnected = false;

  NotificationStreamProvider() {
    _startListening();
  }

  Future<void> _startListening() async {
    try {
      // Subscribe to the notification stream from BitwindowRPC
      _subscription = bitwindow.notificationStream.listen(
        _handleEvent,
        onError: (error) {
          log.e('Notification stream error: $error');
          isConnected = false;
          notifyListeners();
          unawaited(_reconnect());
        },
        onDone: () {
          log.i('Notification stream closed');
          isConnected = false;
          notifyListeners();
          unawaited(_reconnect());
        },
      );

      isConnected = true;
      notifyListeners();
      log.i('Notification stream started successfully');
    } catch (e) {
      log.e('Failed to start notification stream: $e');
      isConnected = false;
      notifyListeners();
      unawaited(_reconnect());
    }
  }

  void _handleEvent(WatchResponse event) {
    log.d('Received notification event: ${event.whichEvent()}');

    if (event.hasTransaction()) {
      _handleTransactionEvent(event.transaction);
    } else if (event.hasTimestampEvent()) {
      _handleTimestampEvent(event.timestampEvent);
    } else if (event.hasSystem()) {
      _handleSystemEvent(event.system);
    }
  }

  void _handleTransactionEvent(TransactionEvent event) {
    String title;
    String content;

    switch (event.type) {
      case TransactionEvent_Type.TYPE_RECEIVED:
        title = 'Transaction Received';
        content = 'Received ${_formatAmount(event.amountSats)} BTC';
        break;
      case TransactionEvent_Type.TYPE_SENT:
        title = 'Transaction Sent';
        content = 'Sent ${_formatAmount(event.amountSats)} BTC';
        break;
      case TransactionEvent_Type.TYPE_CONFIRMED:
        title = 'Transaction Confirmed';
        content = 'Transaction ${_formatTxid(event.txid)} confirmed';
        break;
      default:
        return;
    }

    notificationProvider.add(
      title: title,
      content: content,
      dialogType: DialogType.info,
    );
  }

  void _handleTimestampEvent(TimestampEvent event) {
    String title;
    String content;

    switch (event.type) {
      case TimestampEvent_Type.TYPE_CREATED:
        title = 'Timestamp Created';
        content = 'File "${event.filename}" timestamped';
        break;
      case TimestampEvent_Type.TYPE_CONFIRMED:
        title = 'Timestamp Confirmed';
        content = 'Timestamp for "${event.filename}" confirmed';
        break;
      default:
        return;
    }

    notificationProvider.add(
      title: title,
      content: content,
      dialogType: DialogType.success,
    );
  }

  void _handleSystemEvent(SystemEvent event) {
    String title = 'System Event';
    String content = event.message;
    DialogType type = DialogType.info;

    switch (event.type) {
      case SystemEvent_Type.TYPE_SERVICE_CONNECTED:
        title = 'Service Connected';
        type = DialogType.success;
        break;
      case SystemEvent_Type.TYPE_SERVICE_DISCONNECTED:
        title = 'Service Disconnected';
        type = DialogType.error;
        break;
      case SystemEvent_Type.TYPE_SYNC_COMPLETED:
        title = 'Sync Completed';
        type = DialogType.success;
        break;
      case SystemEvent_Type.TYPE_BLOCK_FOUND:
        title = 'Block Found';
        type = DialogType.success;
        break;
      default:
        break;
    }

    notificationProvider.add(
      title: title,
      content: content,
      dialogType: type,
    );
  }

  String _formatAmount(Int64 sats) {
    final btc = sats.toDouble() / 100000000;
    return btc.toStringAsFixed(8);
  }

  String _formatTxid(String txid) {
    if (txid.length <= 16) return txid;
    return '${txid.substring(0, 8)}...${txid.substring(txid.length - 8)}';
  }

  Future<void> _reconnect() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!isConnected) {
      log.i('Reconnecting notification stream...');
      await _startListening();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
