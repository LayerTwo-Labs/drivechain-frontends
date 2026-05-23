// Regression for #1723: before this fix, the wipe-success header was an
// unconditional green check + "Reset Complete", even when half the files
// failed to delete. Users walked away believing the wipe was clean.
//
// The fix at sail_ui/lib/widgets/reset/reset_confirmation_page.dart gates
// the header on `errorCount`. This test exercises that gating through the
// pure `resetHeaderState` helper so we don't need to mount the whole
// Scaffold + ViewModelBuilder rig just to assert three lines of branching.

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  test('pre-deletion shows confirm state', () {
    expect(resetHeaderState(deletionComplete: false, errorCount: 0), ResetHeaderState.confirm);
    // errorCount is irrelevant before deletion is complete — items can only be
    // pending so a non-zero count would be nonsensical, but lock the behaviour.
    expect(resetHeaderState(deletionComplete: false, errorCount: 5), ResetHeaderState.confirm);
  });

  test('clean wipe shows success state', () {
    expect(resetHeaderState(deletionComplete: true, errorCount: 0), ResetHeaderState.success);
  });

  test('partial wipe shows partial state (the #1723 bug)', () {
    expect(resetHeaderState(deletionComplete: true, errorCount: 1), ResetHeaderState.partial);
    expect(resetHeaderState(deletionComplete: true, errorCount: 99), ResetHeaderState.partial);
  });
}
