import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// The text a page shows on a network that does not serve it: a heading, an intro, then titled sections.
class NetworkUnavailableBody extends StatelessWidget {
  final String heading;
  final String intro;
  final List<(String, String)> sections;

  const NetworkUnavailableBody({super.key, required this.heading, required this.intro, required this.sections});

  @override
  Widget build(BuildContext context) {
    final phone = SailStyleValues.phoneLayout(context);
    final sectionGap = SailSpacing(phone ? SailStyleValues.padding12 : SailStyleValues.padding20);
    final titleGap = SailSpacing(phone ? SailStyleValues.padding04 : SailStyleValues.padding08);

    return Padding(
      padding: phone
          ? const EdgeInsets.only(top: SailStyleValues.padding04)
          : const EdgeInsets.all(SailStyleValues.padding20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          phone ? SailText.primary16(heading, bold: true) : SailText.primary20(heading),
          sectionGap,
          SailText.secondary13(intro),
          for (final (title, body) in sections) ...[
            sectionGap,
            phone ? SailText.primary13(title, bold: true) : SailText.primary15(title),
            titleGap,
            SailText.secondary13(body),
          ],
        ],
      ),
    );
  }
}
