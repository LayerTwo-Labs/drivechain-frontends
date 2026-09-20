import 'package:flutter_test/flutter_test.dart';
import 'package:bitwindow/sol/sol_wallet.dart';
import 'package:sidechain_core/bitcoin.dart';
import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pbenum.dart';

/// The BIP39 test phrase. It is public, so it holds no money.
const testPhrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

/// `solana-keygen recover 'prompt://?key=0/0'` answered with these addresses
/// for the phrase above and an empty passphrase. The sol-drivechain daemon
/// pins the same two values, so the two wallets cannot drift apart.
const account0 = 'HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk';
const account1 = 'Hh8QwFUA6MtVu1qAoq12ucvFHNwCcVTV7hpWjeY1Hztb';

void main() {
  group('solAddressFromMnemonic', () {
    test('account zero matches solana-keygen', () {
      expect(solAddressFromMnemonic(testPhrase), account0);
    });

    test('account one matches solana-keygen', () {
      expect(solAddressFromMnemonic(testPhrase, account: 1), account1);
    });

    test('each account gives another address', () {
      expect(
        solAddressFromMnemonic(testPhrase, account: 2),
        isNot(solAddressFromMnemonic(testPhrase, account: 3)),
      );
    });

    test('one phrase always gives the same address', () {
      expect(
        solAddressFromMnemonic(testPhrase, account: 7),
        solAddressFromMnemonic(testPhrase, account: 7),
      );
    });

    test('extra spaces do not change the address', () {
      expect(solAddressFromMnemonic('  $testPhrase  '), account0);
    });

    test('a phrase that is no mnemonic fails', () {
      expect(() => solAddressFromMnemonic('not a seed phrase'), throwsA(anything));
    });
  });

  group('solDerivationPath', () {
    test('the path names coin type 501', () {
      expect(solDerivationPath(3), "m/44'/501'/3'/0'");
    });
  });

  group('the deposit address', () {
    String depositAddress({int account = 0}) => formatDepositAddress(
      solAddressFromMnemonic(testPhrase, account: account),
      solSidechainSlot,
    );

    test('the daemon and the app build the same address', () {
      // `sol-drivechain-daemon address --slot 8 --pubkey <account0>` prints
      // this exact string.
      expect(depositAddress(), 's8_HAgk14JpMQLgt6rVgv7cBQFJWFto5Dqxi472uT3DKpqk_02365c');
    });

    test('the address names slot 8 and carries a six-character checksum', () {
      expect(depositAddress(account: 1), startsWith('s8_${account1}_'));
      expect(depositAddress(account: 1).length, 's8_${account1}_'.length + 6);
    });
  });

  group('solPegsToL1', () {
    const ecash = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

    test('eCash betanet carries the hosted chain', () {
      expect(solPegsToL1(ecash, 'betanet'), isTrue);
    });

    test('another eCash generation does not', () {
      // Every generation reads as BITCOIN_NETWORK_ECASH.
      expect(solPegsToL1(ecash, 'alphanet'), isFalse);
      expect(solPegsToL1(ecash, 'drynet'), isFalse);
    });

    test('an unknown generation does not', () {
      expect(solPegsToL1(ecash, ''), isFalse);
    });

    test('another L1 does not', () {
      expect(solPegsToL1(BitcoinNetwork.BITCOIN_NETWORK_REGTEST, 'betanet'), isFalse);
      expect(solPegsToL1(BitcoinNetwork.BITCOIN_NETWORK_SIGNET, 'betanet'), isFalse);
      expect(solPegsToL1(BitcoinNetwork.BITCOIN_NETWORK_MAINNET, 'betanet'), isFalse);
    });
  });

  group('isSolSidechain', () {
    const ecash = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

    test('slot 8 with the Solana title on betanet is the SOL chain', () {
      expect(isSolSidechain(8, solSidechainTitle, ecash, 'betanet'), isTrue);
    });

    test('another chain on slot 8 is not the SOL chain', () {
      expect(isSolSidechain(8, 'Thunder', ecash, 'betanet'), isFalse);
    });

    test('an unknown title is not the SOL chain', () {
      expect(isSolSidechain(8, null, ecash, 'betanet'), isFalse);
    });

    test('another slot is not the SOL chain', () {
      expect(isSolSidechain(9, solSidechainTitle, ecash, 'betanet'), isFalse);
    });

    test('the regtest harness claims the same slot and title', () {
      // scripts/regtest-peg.sh claims slot 8 under this same title, and its
      // Solana chain is not the hosted one.
      expect(
        isSolSidechain(8, solSidechainTitle, BitcoinNetwork.BITCOIN_NETWORK_REGTEST, ''),
        isFalse,
      );
    });

    test('alphanet does not carry the hosted chain', () {
      expect(isSolSidechain(8, solSidechainTitle, ecash, 'alphanet'), isFalse);
    });
  });

  group('cacheFitsWallet', () {
    test('the same wallet keeps the cache', () {
      expect(cacheFitsWallet('w1', 'w1'), isTrue);
    });

    test('another wallet drops the cache', () {
      expect(cacheFitsWallet('w1', 'w2'), isFalse);
    });

    test('a wallet that closed drops the cache', () {
      expect(cacheFitsWallet('w1', null), isFalse);
    });

    test('an empty cache never fits', () {
      expect(cacheFitsWallet(null, 'w1'), isFalse);
      expect(cacheFitsWallet(null, null), isFalse);
    });
  });

  group('solBalanceLabel', () {
    test('a read in progress says so', () {
      expect(solBalanceLabel(loading: true, sats: 5000000), 'Reading the SOL balance...');
    });

    test('an error takes the place of the balance', () {
      expect(solBalanceLabel(loading: false, error: 'the node is down'), 'the node is down');
    });

    test('an unread balance prints nothing', () {
      expect(solBalanceLabel(loading: false), '');
    });

    test('a balance prints as bitcoin', () {
      expect(solBalanceLabel(loading: false, sats: 5000000), 'SOL balance: 0.0500,0000 BTC');
    });
  });

  group('satsFromLamports', () {
    test('ten lamports make one satoshi', () {
      expect(satsFromLamports(10), 1);
      expect(satsFromLamports(50000000), 5000000);
    });

    test('a part of a satoshi rounds down', () {
      expect(satsFromLamports(19), 1);
      expect(satsFromLamports(9), 0);
    });
  });
}
