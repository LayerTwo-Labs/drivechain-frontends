import 'package:bitwindow/pages/wallet/wallet_consolidate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

WalletData _wallet({bool watchOnly = false, bool multisig = false}) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: ''),
  sidechains: const [],
  id: 'wallet',
  name: 'wallet',
  gradient: WalletGradient.fromWalletId('wallet'),
  createdAt: DateTime(2026),
  walletType: BinaryType.BINARY_TYPE_ENFORCER,
  isWatchOnly: watchOnly,
  multisig: multisig ? wmpb.MultisigInfo(m: 2, n: 3) : null,
);

void main() {
  test('a single signature wallet may consolidate', () {
    expect(consolidationBlockReason(_wallet()), isNull);
  });

  test('no active wallet blocks the flow', () {
    expect(consolidationBlockReason(null), contains('No wallet'));
  });

  // Consolidation broadcasts on its own, so a wallet that cannot sign alone
  // must stop before the coins freeze.
  test('a watch-only wallet cannot sign a consolidation', () {
    expect(consolidationBlockReason(_wallet(watchOnly: true)), contains('watch-only'));
  });

  test('a multisig wallet goes to the Multisig Lounge', () {
    expect(consolidationBlockReason(_wallet(multisig: true)), contains('Multisig Lounge'));
  });
}
