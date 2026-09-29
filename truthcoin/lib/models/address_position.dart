import 'package:truthcoin/models/voting.dart';

/// One share position, with the wallet address that holds it. The node scopes
/// market_positions to one address, so every read names its address.
class AddressPosition {
  final String address;
  final SharePosition position;

  const AddressPosition(this.address, this.position);
}
