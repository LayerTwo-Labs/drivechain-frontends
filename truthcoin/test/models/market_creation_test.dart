import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/models/market_creation.dart';

void main() {
  group('OpenPeriod', () {
    test('parses a list_open_periods_with_pricing entry', () {
      final period = OpenPeriod.fromJson(
        jsonDecode(
          '{"period_index":21,"cheapest_available_slot_sats":9,"cheapest_available_tier":0,'
          '"slots_available_by_tier":[30,30,30,30,30]}',
        ) as Map<String, dynamic>,
      );

      expect(period.periodIndex, 21);
      expect(period.cheapestSats, 9);
      expect(period.cheapestTier, 0);
      expect(period.slotsByTier, [30, 30, 30, 30, 30]);
      expect(period.label, 'Period 21 · 9 sats · 30 slots');
    });

    test('counts the slots of the cheapest tier', () {
      final period = OpenPeriod.fromJson({
        'period_index': 7,
        'cheapest_available_slot_sats': 312,
        'cheapest_available_tier': 1,
        'slots_available_by_tier': [0, 95, 95, 95, 95],
      });

      expect(period.slotsLeft, 95);
      expect(period.label, 'Period 7 · 312 sats · 95 slots');
    });
  });

  group('NewDecisionDraft', () {
    test('a binary card gives the CLI dimension', () {
      final draft = NewDecisionDraft(periodIndex: 21)
        ..header.text = 'Will eCash use a different DAA than Bitcoin by Jan 1, 2027?'
        ..option0Label.text = 'No'
        ..option1Label.text = 'Yes';

      expect(draft.error, null);
      expect(
        jsonEncode(draft.toDimension()),
        '{"type":"new","period_index":21,"decision_type":"binary",'
        '"header":"Will eCash use a different DAA than Bitcoin by Jan 1, 2027?",'
        '"option_0_label":"No","option_1_label":"Yes"}',
      );
    });

    test('a binary card without labels sends no labels', () {
      final draft = NewDecisionDraft(periodIndex: 3)..header.text = 'Rain?';

      expect(draft.toDimension().containsKey('option_0_label'), false);
      expect(draft.toDimension().containsKey('option_1_label'), false);
    });

    test('a scaled card sends min, max and increment', () {
      final draft = NewDecisionDraft(periodIndex: 3)
        ..type = NewDecisionType.scaled
        ..header.text = 'How many blocks?'
        ..min.text = '10'
        ..max.text = '20'
        ..increment.text = '2';

      expect(draft.error, null);
      expect(
        jsonEncode(draft.toDimension()),
        '{"type":"new","period_index":3,"decision_type":"scaled","header":"How many blocks?",'
        '"min":10.0,"max":20.0,"increment":2.0}',
      );

      draft.max.text = '5';
      expect(draft.error, 'Max must be more than min.');

      draft
        ..max.text = '1'
        ..min.text = '0'
        ..increment.text = '0.3';
      expect(draft.error, 'Max minus min must be a whole number of increments.');

      draft.increment.text = '0.1';
      expect(draft.error, null);

      draft.max.text = 'Infinity';
      expect(draft.error, 'Min, max and increment must be numbers.');
      draft.max.text = 'NaN';
      expect(draft.error, 'Min, max and increment must be numbers.');
    });

    test('a category card needs 2 or more labels', () {
      final draft = NewDecisionDraft(periodIndex: 3)
        ..type = NewDecisionType.category
        ..header.text = 'Which chain wins?'
        ..optionLabels.text = 'Thunder';

      expect(draft.error, 'Write 2 or more option labels.');

      draft.optionLabels.text = 'Thunder, BitNames , ';
      expect(draft.error, null);
      expect(draft.toDimension()['option_labels'], ['Thunder', 'BitNames']);
      expect(draft.outcomeCount, 2);
    });

    test('an untouched card is blank, a card with a label only needs a header', () {
      final draft = NewDecisionDraft(periodIndex: 3);
      expect(draft.isBlank, true);

      draft.option1Label.text = 'Yes';
      expect(draft.isBlank, false);
      expect(draft.error, 'Write a header.');
    });

    test('a scaled card with an edited range is not blank', () {
      final draft = NewDecisionDraft(periodIndex: 3)..type = NewDecisionType.scaled;
      expect(draft.isBlank, true);

      draft.max.text = '100';
      expect(draft.isBlank, false);
      expect(draft.error, 'Write a header.');

      draft.type = NewDecisionType.binary;
      expect(draft.isBlank, true);
    });
  });
}
