import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Represents a peer connection to the Bitcoin client
class Peer {
  final int id;
  final WebSocketChannel channel;

  Peer(this.id, this.channel);
}

/// Flutter implementation of net.gd
/// Handles all networking logic for fast withdrawals
class Net {
  // Debug printing capability
  bool printDebugNet = false;

  // Active peer connection
  Peer? _currentPeer;
  int _nextPeerId = 1;

  // Public getter for connection state
  bool get isConnected => _currentPeer != null;

  // Server signals
  final _fastWithdrawRequested = StreamController<(int, double, String)>.broadcast();
  final _fastWithdrawInvoicePaid = StreamController<(int, String, double, String)>.broadcast();

  // Client signals
  final _fastWithdrawInvoice = StreamController<(double, String)>.broadcast();
  final _fastWithdrawComplete = StreamController<(String, double, String)>.broadcast();

  // Connection signals
  final _connected = StreamController<void>.broadcast();
  final _disconnected = StreamController<void>.broadcast();
  final _connectionFailed = StreamController<String>.broadcast();

  // Stream getters
  Stream<(int, double, String)> get fastWithdrawRequested => _fastWithdrawRequested.stream;
  Stream<(int, String, double, String)> get fastWithdrawInvoicePaid => _fastWithdrawInvoicePaid.stream;
  Stream<(double, String)> get fastWithdrawInvoice => _fastWithdrawInvoice.stream;
  Stream<(String, double, String)> get fastWithdrawComplete => _fastWithdrawComplete.stream;
  Stream<void> get connected => _connected.stream;
  Stream<void> get disconnected => _disconnected.stream;
  Stream<String> get connectionFailed => _connectionFailed.stream;

  // Server configuration
  static const String serverLocalhost = '127.0.0.1';
  static const String serverL2LGA = '172.105.148.135';
  static const int port = 8382;

  /// Connect to the Bitcoin client
  Future<void> connect(String host) async {
    if (_currentPeer != null) {
      if (printDebugNet) print('Already connected to a peer');
      return;
    }

    try {
      final uri = Uri.parse('ws://$host:$port');
      if (printDebugNet) print('Connecting to $uri');
      
      final channel = WebSocketChannel.connect(uri);
      
      // Wait for connection
      await channel.ready;

      // Create new peer
      _currentPeer = Peer(_nextPeerId++, channel);

      if (printDebugNet) {
        print('Connected to Bitcoin client');
        print('Peer ID: ${_currentPeer?.id}');
      }

      // Listen for messages
      channel.stream.listen(
        (dynamic message) {
          try {
            if (message is String) {
              _handleMessage(jsonDecode(message));
            } else {
              _handleMessage(message);
            }
          } catch (e) {
            if (printDebugNet) print('Error handling message: $e');
          }
        },
        onDone: _handleDisconnect,
        onError: _handleError,
        cancelOnError: false,
      );

      _connected.add(null);
    } catch (e) {
      if (printDebugNet) print('Connection failed: $e');
      _connectionFailed.add(e.toString());
      _currentPeer = null;
    }
  }

  /// Disconnect from the Bitcoin client
  void disconnect() {
    _currentPeer?.channel.sink.close();
    _currentPeer = null;
    if (printDebugNet) print('Disconnected from Bitcoin client');
  }

  /// Handle incoming messages from the Bitcoin client
  void _handleMessage(dynamic message) {
    if (message is! Map<String, dynamic>) {
      if (printDebugNet) print('Invalid message format: $message');
      return;
    }

    final type = message['type'] as String?;
    final data = message['data'] as Map<String, dynamic>?;

    if (type == null || data == null) {
      if (printDebugNet) print('Invalid message structure: $message');
      return;
    }

    if (printDebugNet) print('Received message: $message');

    switch (type) {
      case 'fast_withdraw_invoice':
        _handleFastWithdrawInvoice(data);
        break;
      case 'fast_withdraw_complete':
        _handleFastWithdrawComplete(data);
        break;
    }
  }

  void _handleDisconnect() {
    _currentPeer = null;
    _disconnected.add(null);
    if (printDebugNet) print('Disconnected from Bitcoin client');
  }

  void _handleError(dynamic error) {
    if (printDebugNet) print('WebSocket error: $error');
    _connectionFailed.add(error.toString());
    disconnect();
  }

  void _handleFastWithdrawInvoice(Map<String, dynamic> data) {
    final amount = (data['amount'] as num).toDouble();
    final destination = data['destination'] as String;
    
    if (printDebugNet) {
      print('Received fast withdrawal invoice');
      print('Amount: $amount');
      print('Destination: $destination');
    }

    _fastWithdrawInvoice.add((amount, destination));
  }

  void _handleFastWithdrawComplete(Map<String, dynamic> data) {
    final txid = data['txid'] as String;
    final amount = (data['amount'] as num).toDouble();
    final destination = data['destination'] as String;

    if (printDebugNet) {
      print('Fast withdraw completed!');
      print('Amount: $amount');
      print('Destination: $destination');
      print('Txid: $txid');
    }

    _fastWithdrawComplete.add((txid, amount, destination));
  }

  /// Send a message to the server
  void _sendMessage(Map<String, dynamic> message) {
    if (_currentPeer == null) {
      if (printDebugNet) print('Not connected to Bitcoin client');
      return;
    }

    final jsonStr = jsonEncode(message);
    if (printDebugNet) print('Sending message: $jsonStr');
    _currentPeer?.channel.sink.add(jsonStr);
  }

  /// Request a fast withdrawal
  Future<void> requestFastWithdraw(double amount, String destination) async {
    if (_currentPeer == null) {
      if (printDebugNet) print('Not connected to Bitcoin client');
      return;
    }

    if (printDebugNet) {
      print('Sending fast withdrawal request');
      print('Amount: $amount');
      print('Destination: $destination');
      print('Peer: ${_currentPeer?.id}');
    }

    _sendMessage({
      'type': 'request_fast_withdraw',
      'data': {
        'amount': amount,
        'destination': destination,
      },
    });

    _fastWithdrawRequested.add((_currentPeer!.id, amount, destination));
  }

  /// Mark an invoice as paid
  Future<void> invoicePaid(String txid, double amount, String destination) async {
    if (_currentPeer == null) {
      if (printDebugNet) print('Not connected to Bitcoin client');
      return;
    }

    if (printDebugNet) {
      print('Marking invoice as paid');
      print('Amount: $amount');
      print('Destination: $destination');
      print('Txid: $txid');
      print('Peer: ${_currentPeer?.id}');
    }

    _sendMessage({
      'type': 'invoice_paid',
      'data': {
        'txid': txid,
        'amount': amount,
        'destination': destination,
      },
    });

    _fastWithdrawInvoicePaid.add((_currentPeer!.id, txid, amount, destination));
  }

  // Cleanup
  void dispose() {
    disconnect();
    _fastWithdrawRequested.close();
    _fastWithdrawInvoicePaid.close();
    _fastWithdrawInvoice.close();
    _fastWithdrawComplete.close();
    _connected.close();
    _disconnected.close();
    _connectionFailed.close();
  }
}