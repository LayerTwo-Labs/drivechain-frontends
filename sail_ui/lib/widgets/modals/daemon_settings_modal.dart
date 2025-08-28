import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class DaemonConnectionDetailsModal extends StatefulWidget {
  final RPCConnection connection;

  const DaemonConnectionDetailsModal({super.key, required this.connection});

  @override
  State<DaemonConnectionDetailsModal> createState() => _DaemonConnectionDetailsModalState();
}

class _DaemonConnectionDetailsModalState extends State<DaemonConnectionDetailsModal> {
  List<String> args = [];

  @override
  void initState() {
    super.initState();
    _loadArgs();
  }

  Future<void> _loadArgs() async {
    final loadedArgs = await widget.connection.binaryArgs(widget.connection.conf);
    loadedArgs.removeWhere((arg) => arg.contains('pass'));
    if (mounted) {
      setState(() {
        args = loadedArgs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.sailTheme.colors.backgroundSecondary,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SailCard(
          padding: true,
          title: '${widget.connection.binary.name} Connection Details',
          withCloseButton: true,
          child: Padding(
            padding: const EdgeInsets.all(SailStyleValues.padding16),
            child: SingleChildScrollView(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StaticField(label: 'Host', value: widget.connection.conf.host, copyable: true),
                  StaticField(label: 'Port', value: widget.connection.binary.port.toString(), copyable: true),
                  if (args.isNotEmpty)
                    StaticField(label: 'Binary Arguments', value: args.join(' \\\n'), copyable: true),
                  const SizedBox(height: SailStyleValues.padding08),
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [SailButton(label: 'Close', onPressed: () async => Navigator.pop(context))],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
