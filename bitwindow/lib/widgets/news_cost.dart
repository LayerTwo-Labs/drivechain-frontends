import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Prices a CoinNews action and warns the user the first time they pay for one.
class NewsCost {
  static final Map<String, NewsFeeEstimate> _cache = {};

  /// Estimated cost of the action. Cached per body so a hover costs one call.
  static Future<NewsFeeEstimate?> estimate(NewsAction action, {String body = ''}) async {
    final key = '${action.name}:${body.length}';
    final hit = _cache[key];
    if (hit != null) {
      return hit;
    }

    try {
      final estimate = await GetIt.I.get<BitwindowRPC>().misc.estimateNewsFee(action, body: body);
      _cache[key] = estimate;
      return estimate;
    } catch (_) {
      // a missing estimate must not block voting
      return null;
    }
  }

  /// Shows the on-chain warning the first time the user votes or comments.
  /// Returns false only when the user backs out.
  static Future<bool> confirmFirstTime(BuildContext context, NewsAction action) async {
    final settings = GetIt.I.get<ClientSettings>();
    final isVote = action == NewsAction.NEWS_ACTION_VOTE;

    final seen = isVote
        ? (await settings.getValue(VoteWarningSeenSetting())).value
        : (await settings.getValue(CommentWarningSeenSetting())).value;
    if (seen) {
      return true;
    }

    final estimate = await NewsCost.estimate(action, body: isVote ? '' : 'x' * 120);
    if (!context.mounted) {
      return false;
    }

    final confirmed = await _showWarning(context, isVote: isVote, estimate: estimate);
    if (!confirmed) {
      return false;
    }

    await settings.setValue(
      isVote ? VoteWarningSeenSetting(newValue: true) : CommentWarningSeenSetting(newValue: true),
    );
    return true;
  }

  static Future<bool> _showWarning(
    BuildContext context, {
    required bool isVote,
    required NewsFeeEstimate? estimate,
  }) async {
    final action = isVote ? 'Voting' : 'Commenting';
    var confirmed = false;

    await showThemedDialog(
      context: context,
      builder: (context) => SailDialog(
        title: '$action costs a fee',
        actions: [
          SailButton(
            label: 'Cancel',
            variant: ButtonVariant.ghost,
            onPressed: () async => Navigator.of(context).pop(),
          ),
          SailButton(
            label: isVote ? 'Vote' : 'Comment',
            onPressed: () async {
              confirmed = true;
              Navigator.of(context).pop();
            },
          ),
        ],
        child: SizedBox(
          width: 420,
          child: SailColumn(
            spacing: SailStyleValues.padding12,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13(
                '$action writes a transaction to the chain, so it costs a network fee and lands in about ten minutes.',
              ),
              if (estimate != null) SailText.primary13(formatFee(estimate), bold: true),
              SailText.secondary12('You only see this once.'),
            ],
          ),
        ),
      ),
    );

    return confirmed;
  }
}

/// Renders an estimate as the sats it costs, at the rate it assumes.
String formatFee(NewsFeeEstimate estimate) {
  final rate = estimate.feeSatPerVbyte.toStringAsFixed(1);
  return '≈ ${estimate.feeSats} sats  ·  ${estimate.vsize} vB at $rate sat/vB';
}

/// Wraps a control that spends money, so hovering it reveals the cost.
class NewsCostTooltip extends StatefulWidget {
  final NewsAction action;
  final String body;
  final Widget child;

  const NewsCostTooltip({
    super.key,
    required this.action,
    required this.child,
    this.body = '',
  });

  @override
  State<NewsCostTooltip> createState() => _NewsCostTooltipState();
}

class _NewsCostTooltipState extends State<NewsCostTooltip> {
  NewsFeeEstimate? _estimate;
  bool _asked = false;

  Future<void> _load() async {
    if (_asked) {
      return;
    }
    _asked = true;
    final estimate = await NewsCost.estimate(widget.action, body: widget.body);
    if (!mounted) {
      return;
    }
    setState(() => _estimate = estimate);
  }

  @override
  Widget build(BuildContext context) {
    final estimate = _estimate;
    return MouseRegion(
      onEnter: (_) => _load(),
      child: SailTooltip(
        message: estimate == null ? 'Checking the fee…' : formatFee(estimate),
        child: widget.child,
      ),
    );
  }
}
