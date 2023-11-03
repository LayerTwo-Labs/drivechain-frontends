// class for connecting to a basic bitcoin core rpc interface
// also includes functions for checking whether the connection
// is live, and if not, what error message the node returned
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/pages/tabs/settings_tab.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  final _log = Logger(level: Level.debug);

  RPCConnection()
      : connectionError = '',
        connected = false;

  Future<void> createClient();

  // ping method that tests whether the connection is successful
  // should throw if call is not successful
  Future<void> ping();
  Future<(bool, String?)> testConnection() async {
    try {
      await ping();
      connectionError = null;
      connected = true;
    } catch (error) {
      _log.e('could not ping: ${error.toString()}!');
      connectionError = error.toString();
      connected = false;
    }
    notifyListeners();

    return (connected, connectionError);
  }

  // values for tracking connection state, and error (if any)
  late SingleNodeConnectionSettings connectionSettings;
  String? connectionError;
  bool connected;
}
