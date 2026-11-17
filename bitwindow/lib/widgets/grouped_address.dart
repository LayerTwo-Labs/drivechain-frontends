import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

final _addressPrefix = RegExp(r'^(?:[a-z]+:|(?:bc|tb|bcrt)1)', caseSensitive: false);

/// An address in groups of five characters. The first group holds the
/// `ecash:` or `bc1` prefix in front of its five characters.
List<String> addressGroups(String address) {
  final prefix = _addressPrefix.firstMatch(address)?.group(0) ?? '';
  final rest = address.substring(prefix.length);
  final groups = [
    for (var i = 0; i < rest.length; i += 5) rest.substring(i, min(i + 5, rest.length)),
  ];
  if (groups.isEmpty) {
    return prefix.isEmpty ? [] : [prefix];
  }
  groups[0] = '$prefix${groups[0]}';
  return groups;
}

/// The full address in groups of five, with the first and the last group in medium weight.
class GroupedAddress extends StatelessWidget {
  final String address;
  final Color? color;

  const GroupedAddress(this.address, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final groups = addressGroups(address);
    final style = SailStyleValues.thirteen.copyWith(
      color: color ?? theme.colors.text,
      fontFamily: theme.chrome.fontFamily ?? SailFonts.mono,
    );
    final medium = style.copyWith(fontWeight: SailStyleValues.boldWeight);

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const TextSpan(text: ' '),
            TextSpan(text: groups[i], style: i == 0 || i == groups.length - 1 ? medium : style),
          ],
        ],
      ),
      style: style,
    );
  }
}
