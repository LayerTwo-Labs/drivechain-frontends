import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/binary_provider.dart';

class WalletBalance {
  final String name;
  final double confirmedBalance;
  final double unconfirmedBalance;

  const WalletBalance({
    required this.name,
    required this.confirmedBalance,
    required this.unconfirmedBalance,
  });

  double get totalBalance => confirmedBalance + unconfirmedBalance;
}

class WalletButtonModel extends ChangeNotifier {
  final BinaryProvider _binaryProvider = GetIt.I.get<BinaryProvider>();
  List<WalletBalance> _balances = [];
  double _totalBalance = 0.0;
  bool _loading = true;
  String? _address;
  bool _wasConnected = false;

  WalletButtonModel() {
    _binaryProvider.addListener(_onBinaryProviderChanged);
    _updateBalances();
    _updateAddress();
  }

  List<WalletBalance> get balances => _balances;
  double get totalBalance => _totalBalance;
  bool get loading => _loading;
  String? get address => _address;

  void _onBinaryProviderChanged() {
    _updateBalances();

    // Check if BitWindow just connected
    final isConnected = _binaryProvider.bitwindowRPC.connected == true;
    if (isConnected && !_wasConnected) {
      _updateAddress();
    }
    _wasConnected = isConnected;
  }

  Future<void> _updateBalances() async {
    _loading = true;
    notifyListeners();

    final newBalances = <WalletBalance>[];
    var total = 0.0;

    // BitWindow balance
    if (_binaryProvider.bitwindowRPC.connected == true) {
      try {
        final (confirmed, unconfirmed) = await _binaryProvider.bitwindowRPC.balance();
        newBalances.add(
          WalletBalance(
            name: 'BitWindow',
            confirmedBalance: confirmed,
            unconfirmedBalance: unconfirmed,
          ),
        );
        total += confirmed + unconfirmed;
      } catch (e) {
        // Handle error
      }
    }

    // Thunder balance
    if (_binaryProvider.thunderRPC.connected == true) {
      try {
        final (confirmed, unconfirmed) = await _binaryProvider.thunderRPC.balance();
        newBalances.add(
          WalletBalance(
            name: 'Thunder',
            confirmedBalance: confirmed,
            unconfirmedBalance: unconfirmed,
          ),
        );
        total += confirmed + unconfirmed;
      } catch (e) {
        // Handle error
      }
    }

    // BitNames balance
    if (_binaryProvider.bitnamesRPC.connected == true) {
      try {
        final (confirmed, unconfirmed) = await _binaryProvider.bitnamesRPC.balance();
        newBalances.add(
          WalletBalance(
            name: 'BitNames',
            confirmedBalance: confirmed,
            unconfirmedBalance: unconfirmed,
          ),
        );
        total += confirmed + unconfirmed;
      } catch (e) {
        // Handle error
      }
    }

    _balances = newBalances;
    _totalBalance = total;
    _loading = false;
    notifyListeners();
  }

  Future<void> _updateAddress() async {
    if (_binaryProvider.bitwindowRPC.connected == true) {
      try {
        _address = await _binaryProvider.bitwindowRPC.wallet.getNewAddress();
        notifyListeners();
      } catch (e) {
        debugPrint('Error getting BitWindow address: $e');
      }
    }
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(_onBinaryProviderChanged);
    super.dispose();
  }
}
