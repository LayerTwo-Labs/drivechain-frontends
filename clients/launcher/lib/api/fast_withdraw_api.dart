// Fast Withdrawal WebSocket API Definition
// Based on the Godot implementation in net.gd

/// Server configuration
class FastWithdrawConfig {
  static const String serverLocalhost = '127.0.0.1';
  static const String serverProduction = '172.105.148.135';
  static const int port = 8382;
}

/// Base class for all WebSocket messages
abstract class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebSocketMessage(this.type, this.data);

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };
}

/// Client -> Server Messages

class RequestFastWithdraw extends WebSocketMessage {
  RequestFastWithdraw({
    required double amount,
    required String destination,
  }) : super('request_fast_withdraw', {
          'amount': amount,
          'destination': destination,
        });
}

class InvoicePaid extends WebSocketMessage {
  InvoicePaid({
    required String txid,
    required double amount,
    required String destination,
  }) : super('invoice_paid', {
          'txid': txid,
          'amount': amount,
          'destination': destination,
        });
}

/// Server -> Client Messages

class FastWithdrawInvoice extends WebSocketMessage {
  FastWithdrawInvoice({
    required double amount,
    required String destination,
  }) : super('fast_withdraw_invoice', {
          'amount': amount,
          'destination': destination, // L2 address to pay to
        });

  factory FastWithdrawInvoice.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FastWithdrawInvoice(
      amount: data['amount'] as double,
      destination: data['destination'] as String,
    );
  }
}

class FastWithdrawComplete extends WebSocketMessage {
  FastWithdrawComplete({
    required String txid,
    required double amount,
    required String destination,
  }) : super('fast_withdraw_complete', {
          'txid': txid, // Mainchain transaction ID
          'amount': amount,
          'destination': destination, // Original mainchain destination
        });

  factory FastWithdrawComplete.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FastWithdrawComplete(
      txid: data['txid'] as String,
      amount: data['amount'] as double,
      destination: data['destination'] as String,
    );
  }
}

class ConnectionStatus extends WebSocketMessage {
  ConnectionStatus({
    required String status,
    String? error,
  }) : super('connection_status', {
          'status': status,
          'error': error,
        });

  factory ConnectionStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ConnectionStatus(
      status: data['status'] as String,
      error: data['error'] as String?,
    );
  }

  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String failed = 'failed';
}

class ErrorMessage extends WebSocketMessage {
  ErrorMessage({
    required String code,
    required String message,
    Map<String, dynamic>? details,
  }) : super('error', {
          'code': code,
          'message': message,
          'details': details,
        });

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ErrorMessage(
      code: data['code'] as String,
      message: data['message'] as String,
      details: data['details'] as Map<String, dynamic>?,
    );
  }
}

class DebugMessage extends WebSocketMessage {
  DebugMessage({
    required bool enabled,
    required String message,
    Map<String, dynamic>? details,
  }) : super('debug', {
          'enabled': enabled,
          'message': message,
          'details': details,
        });

  factory DebugMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DebugMessage(
      enabled: data['enabled'] as bool,
      message: data['message'] as String,
      details: data['details'] as Map<String, dynamic>?,
    );
  }
}

/// Helper function to parse incoming WebSocket messages
WebSocketMessage? parseWebSocketMessage(Map<String, dynamic> json) {
  final type = json['type'] as String;
  switch (type) {
    case 'fast_withdraw_invoice':
      return FastWithdrawInvoice.fromJson(json);
    case 'fast_withdraw_complete':
      return FastWithdrawComplete.fromJson(json);
    case 'connection_status':
      return ConnectionStatus.fromJson(json);
    case 'error':
      return ErrorMessage.fromJson(json);
    case 'debug':
      return DebugMessage.fromJson(json);
    default:
      return null;
  }
}
