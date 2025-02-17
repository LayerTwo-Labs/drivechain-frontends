import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ExpandableListEntry extends StatefulWidget {
  final SingleValueContainer entry;
  final Widget expandedEntry;

  const ExpandableListEntry({
    super.key,
    required this.entry,
    required this.expandedEntry,
  });

  @override
  State<ExpandableListEntry> createState() => _ExpandableListEntryState();
}

class _ExpandableListEntryState extends State<ExpandableListEntry> {
  bool expanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding10,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () async {
              setState(() {
                expanded = !expanded;
              });
            },
            child: widget.entry,
          ),
          if (expanded) widget.expandedEntry,
        ],
      ),
    );
  }
}
