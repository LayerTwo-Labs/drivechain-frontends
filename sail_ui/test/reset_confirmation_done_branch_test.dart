// Regression for #1723 (defensive arm): if the orchestrator finishes the
// reset stream without emitting an event for every preview row, the rows
// that never got an event were left at `pending` forever — greyed-out and
// confusing, with no way for the user to know whether they were deleted.
//
// The fix at sail_ui/lib/widgets/reset/reset_confirmation_page.dart handles
// the `done` event by flipping any still-pending/in-progress items to
// `error` with a "No result from orchestrator" message. This test pins
// that behaviour via the pure `applyDoneEventToItems` helper so the safety
// net can't silently regress.

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  test('flips pending items to error with default message', () {
    final items = [
      DeleteItem(path: '/a', status: DeleteItemStatus.pending),
      DeleteItem(path: '/b', status: DeleteItemStatus.pending),
    ];

    applyDoneEventToItems(items);

    for (final item in items) {
      expect(item.status, DeleteItemStatus.error);
      expect(item.errorMessage, 'No result from orchestrator');
    }
  });

  test('flips in-progress items to error too', () {
    final item = DeleteItem(path: '/a', status: DeleteItemStatus.inProgress);

    applyDoneEventToItems([item]);

    expect(item.status, DeleteItemStatus.error);
    expect(item.errorMessage, 'No result from orchestrator');
  });

  test('leaves already-resolved items alone', () {
    final success = DeleteItem(path: '/s', status: DeleteItemStatus.success);
    final preExistingError = DeleteItem(
      path: '/e',
      status: DeleteItemStatus.error,
      errorMessage: 'disk full',
    );

    applyDoneEventToItems([success, preExistingError]);

    expect(success.status, DeleteItemStatus.success);
    expect(success.errorMessage, isNull);
    // Pre-existing error message must not be clobbered — the user cares
    // about the real failure cause, not the generic done-branch message.
    expect(preExistingError.status, DeleteItemStatus.error);
    expect(preExistingError.errorMessage, 'disk full');
  });

  test('honors custom message override', () {
    final item = DeleteItem(path: '/a', status: DeleteItemStatus.pending);

    applyDoneEventToItems([item], message: 'stream closed early');

    expect(item.errorMessage, 'stream closed early');
  });

  test('handles empty list without throwing', () {
    expect(() => applyDoneEventToItems(<DeleteItem>[]), returnsNormally);
  });
}
