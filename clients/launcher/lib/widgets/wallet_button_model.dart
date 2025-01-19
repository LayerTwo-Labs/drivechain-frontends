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

  WalletButtonModel() {
    // Listen to changes in binary provider
    _binaryProvider.addListener(_updateBalances);
    _updateBalances();
  }

  List<WalletBalance> get balances => _balances;
  double get totalBalance => _totalBalance;
  bool get loading => _loading;

  Future<void> _updateBalances() async {
    _loading = true;
    notifyListeners();

    final newBalances = <WalletBalance>[];
    var total = 0.0;

    // Add other RPCs similarly...
    if (_binaryProvider.bitwindowRPC?.connected == true) {
      try {
        final (confirmed, unconfirmed) = await _binaryProvider.bitwindowRPC!.balance();
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

    if (_binaryProvider.thunderRPC?.connected == true) {
      try {
        final (confirmed, unconfirmed) = await _binaryProvider.thunderRPC!.balance();
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

    _balances = newBalances;
    _totalBalance = total;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(_updateBalances);
    super.dispose();
  }
}
