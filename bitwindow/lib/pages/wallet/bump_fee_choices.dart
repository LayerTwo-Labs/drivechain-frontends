import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// What the bump-fee dialog offers for one preview: which buttons it draws, and
/// the line it prints under them. The buttons and the line come from one place,
/// so the dialog can never point at an action it does not offer.
class BumpFeeChoices {
  /// The wallet can sign a replacement, so the dialog keeps the Replace button.
  /// A fee rate that is too low disables it, and never removes it.
  final bool showReplace;

  /// The backend funds the higher fee from another coin, so Replace works even
  /// with no plan on screen.
  final bool replaceWithoutPlan;

  /// The transaction has no change output, so the fee comes out of a payment
  /// only when the user picks that output.
  final bool showOverride;

  /// A child transaction can lift this one instead.
  final bool showAccelerate;

  /// What went wrong, and what the user does next. Empty when a plan exists.
  final String reason;

  const BumpFeeChoices({
    required this.showReplace,
    required this.replaceWithoutPlan,
    required this.showOverride,
    required this.showAccelerate,
    required this.reason,
  });

  factory BumpFeeChoices.of(wmpb.PreviewBumpFeeResponse preview, {required bool pickOutput}) {
    final ownsAnOutput = preview.outputs.any((o) => o.isMine);
    final hasChange = preview.outputs.any((o) => o.isChange);
    final hasPayableOutput = preview.outputs.any((o) => o.address.isNotEmpty);

    // A child already spends this transaction. A replacement must outpay that
    // child, and a second child cannot spend an output the first one took.
    final showAccelerate = !preview.hasChild && ownsAnOutput && (!preview.canReplace || !hasChange);

    return BumpFeeChoices(
      showReplace: preview.canReplace,
      replaceWithoutPlan: preview.canReplace && preview.addsInputs,
      showOverride: preview.canReplace && !hasChange && !pickOutput && hasPayableOutput,
      showAccelerate: showAccelerate,
      reason: _reason(preview, ownsAnOutput: ownsAnOutput, showAccelerate: showAccelerate),
    );
  }

  static String _reason(
    wmpb.PreviewBumpFeeResponse preview, {
    required bool ownsAnOutput,
    required bool showAccelerate,
  }) {
    if (preview.reason.isEmpty) {
      return '';
    }
    if (preview.hasChild) {
      return '${preview.reason}. Bump the fee of that transaction instead.';
    }
    if (showAccelerate) {
      return '${preview.reason}. We suggest CPFP instead.';
    }
    if (!preview.canReplace && !ownsAnOutput) {
      return '${preview.reason}. This wallet owns no output of it, so CPFP cannot speed it up either.';
    }
    return preview.reason;
  }
}
