import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

WalletData _wallet(List<wmpb.AddressType> types) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: ''),
  sidechains: const [],
  id: 'W1',
  name: 'W1',
  gradient: WalletGradient.fromWalletId('W1'),
  createdAt: DateTime.utc(2026, 1, 1),
  walletType: BinaryType.BINARY_TYPE_UNSPECIFIED,
  isElectrum: true,
  receiveAddressTypes: types,
);

void main() {
  // A wallet on an explicit path derives one kind. Asking for another makes the
  // backend refuse the address on every poll.
  test('the wallet leads with its own kind', () {
    expect(
      _wallet([wmpb.AddressType.ADDRESS_TYPE_TAPROOT]).defaultAddressType,
      wmpb.AddressType.ADDRESS_TYPE_TAPROOT,
    );
    expect(
      _wallet([
        wmpb.AddressType.ADDRESS_TYPE_SEGWIT,
        wmpb.AddressType.ADDRESS_TYPE_TAPROOT,
      ]).defaultAddressType,
      wmpb.AddressType.ADDRESS_TYPE_SEGWIT,
    );
  });

  // Before the wallet stream reports anything, the backend picks the kind.
  test('an unreported wallet leaves the choice to the backend', () {
    expect(_wallet(const []).defaultAddressType, wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED);
  });
}
