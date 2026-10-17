import 'dart:math';

import 'package:flutter/widgets.dart';

/// One open period from list_open_periods_with_pricing.
class OpenPeriod {
  final int periodIndex;

  /// Sats the next claim in this period costs.
  final int cheapestSats;
  final int cheapestTier;

  /// Unlocked slots left in each of the 5 tiers.
  final List<int> slotsByTier;

  const OpenPeriod({
    required this.periodIndex,
    required this.cheapestSats,
    required this.cheapestTier,
    required this.slotsByTier,
  });

  factory OpenPeriod.fromJson(Map<String, dynamic> json) {
    return OpenPeriod(
      periodIndex: json['period_index'] as int,
      cheapestSats: json['cheapest_available_slot_sats'] as int,
      cheapestTier: json['cheapest_available_tier'] as int,
      slotsByTier: [for (final slots in json['slots_available_by_tier'] as List) slots as int],
    );
  }

  int get slotsLeft => cheapestTier < slotsByTier.length ? slotsByTier[cheapestTier] : 0;

  String get label => 'Period $periodIndex · $cheapestSats sats · $slotsLeft slots';
}

const _defaultMin = '0';
const _defaultMax = '1';
const _defaultIncrement = '1';

enum NewDecisionType {
  binary('Binary'),
  scaled('Scaled'),
  category('Category');

  const NewDecisionType(this.label);

  final String label;
}

/// The inputs of one "New decision" card.
class NewDecisionDraft {
  int? periodIndex;
  NewDecisionType type = NewDecisionType.binary;

  final header = TextEditingController();
  final option0Label = TextEditingController();
  final option1Label = TextEditingController();
  final min = TextEditingController(text: _defaultMin);
  final max = TextEditingController(text: _defaultMax);
  final increment = TextEditingController(text: _defaultIncrement);
  final optionLabels = TextEditingController();

  NewDecisionDraft({this.periodIndex});

  List<String> get categoryLabels =>
      optionLabels.text.split(',').map((label) => label.trim()).where((label) => label.isNotEmpty).toList();

  /// A card the author did not touch adds no dimension to the market.
  /// Only the fields of the picked type count, as the card shows only those.
  bool get isBlank =>
      header.text.trim().isEmpty &&
      switch (type) {
        NewDecisionType.binary => option0Label.text.trim().isEmpty && option1Label.text.trim().isEmpty,
        NewDecisionType.scaled =>
          min.text.trim() == _defaultMin &&
              max.text.trim() == _defaultMax &&
              increment.text.trim() == _defaultIncrement,
        NewDecisionType.category => optionLabels.text.trim().isEmpty,
      };

  /// Number of outcomes the decision gives the market.
  int get outcomeCount => type == NewDecisionType.category ? categoryLabels.length : 2;

  /// Why the node would refuse this card, or null when it fits.
  String? get error {
    if (periodIndex == null) return 'Pick a period.';
    if (header.text.trim().isEmpty) return 'Write a header.';
    switch (type) {
      case NewDecisionType.binary:
        return null;
      case NewDecisionType.scaled:
        final low = double.tryParse(min.text.trim());
        final high = double.tryParse(max.text.trim());
        final step = double.tryParse(increment.text.trim());
        if (low == null || high == null || step == null || !low.isFinite || !high.isFinite || !step.isFinite) {
          return 'Min, max and increment must be numbers.';
        }
        if (high <= low) return 'Max must be more than min.';
        if (step <= 0) return 'The increment must be more than 0.';
        if (!_isStepAligned(high - low, step)) return 'Max minus min must be a whole number of increments.';
        return null;
      case NewDecisionType.category:
        if (categoryLabels.length < 2) return 'Write 2 or more option labels.';
        return null;
    }
  }

  /// The `new` DimensionInput that market_create takes.
  Map<String, dynamic> toDimension() {
    final dimension = <String, dynamic>{
      'type': 'new',
      'period_index': periodIndex,
      'decision_type': type.name,
      'header': header.text.trim(),
    };
    switch (type) {
      case NewDecisionType.binary:
        final no = option0Label.text.trim();
        final yes = option1Label.text.trim();
        if (no.isNotEmpty) dimension['option_0_label'] = no;
        if (yes.isNotEmpty) dimension['option_1_label'] = yes;
      case NewDecisionType.scaled:
        dimension['min'] = double.parse(min.text.trim());
        dimension['max'] = double.parse(max.text.trim());
        dimension['increment'] = double.parse(increment.text.trim());
      case NewDecisionType.category:
        dimension['option_labels'] = categoryLabels;
    }
    return dimension;
  }

  void dispose() {
    header.dispose();
    option0Label.dispose();
    option1Label.dispose();
    min.dispose();
    max.dispose();
    increment.dispose();
    optionLabels.dispose();
  }
}

/// The tolerance of is_step_aligned in truthcoin-dc, so the form refuses what the node refuses.
bool _isStepAligned(double delta, double step) {
  final k = (delta / step).roundToDouble();
  final tolerance = max(step.abs() * 1e-9, 1e-12);
  return (delta - k * step).abs() <= tolerance;
}
