import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/utils/navigation_registry.dart';
import 'package:bitwindow/widgets/fork_mode_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/walletpsbt/v1/walletpsbt.pb.dart';

void main() {
  group('forwardSubtabAfterClaim', () {
    test('a clean split run forwards to the send tab', () {
      expect(forwardSubtabAfterClaim(drafted: 1, firstError: null), WalletSubtabs.send);
    });

    test('a broadcast-only run stays on the current tab', () {
      expect(forwardSubtabAfterClaim(drafted: 0, firstError: null), isNull);
    });

    test('a failed run stays put so the user reads the error', () {
      expect(forwardSubtabAfterClaim(drafted: 1, firstError: Exception('boom')), isNull);
    });
  });

  group('showClaimCard', () {
    // A split reserves every coin it spends before its first await, so the
    // claims read empty while the build runs.
    test('the card outlives its own claims while a split builds', () {
      expect(
        showClaimCard(hasFundsToClaim: false, hasClaims: false, dismissed: true, splitInFlight: true),
        isTrue,
      );
    });

    test('the card shows while claimable coins wait', () {
      expect(
        showClaimCard(hasFundsToClaim: true, hasClaims: true, dismissed: false, splitInFlight: false),
        isTrue,
      );
    });

    test('the card hides once every coin is swept', () {
      expect(
        showClaimCard(hasFundsToClaim: true, hasClaims: false, dismissed: false, splitInFlight: false),
        isFalse,
      );
    });

    test('the card hides when the user dismissed it', () {
      expect(
        showClaimCard(hasFundsToClaim: true, hasClaims: true, dismissed: true, splitInFlight: false),
        isFalse,
      );
    });
  });

  group('draftTabIndex', () {
    final drafts = [PsbtDraft(id: 'a'), PsbtDraft(id: 'b'), PsbtDraft(id: 'c')];

    test('a draft sits at its list index plus one', () {
      expect(SendPageViewModel.draftTabIndex(drafts, 'a'), 1);
      expect(SendPageViewModel.draftTabIndex(drafts, 'c'), 3);
    });

    test('an unknown draft falls back to the create form', () {
      expect(SendPageViewModel.draftTabIndex(drafts, 'gone'), 0);
    });
  });
}
