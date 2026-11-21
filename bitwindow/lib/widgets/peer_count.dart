import 'package:bitwindow/pages/root_page.dart';
import 'package:bitwindow/providers/peers_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// "N peers" with a tooltip that lists the peers. It reads the list while the
/// pointer is over it.
class PeerCount extends StatefulWidget {
  final int count;

  const PeerCount({super.key, required this.count});

  @override
  State<PeerCount> createState() => _PeerCountState();
}

class _PeerCountState extends State<PeerCount> {
  PeersProvider get _peers => GetIt.I.get<PeersProvider>();
  bool _listening = false;

  void _listen(bool on) {
    if (on == _listening) {
      return;
    }
    _listening = on;
    if (on) {
      _peers.addListener(_onChange);
    } else {
      _peers.removeListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _listen(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _peers.fetch().then((_) => _onChange()),
      child: MouseRegion(
        onEnter: (_) => _listen(true),
        onExit: (_) => _listen(false),
        child: SailTooltip(
          message: _peers.peers.map((e) => 'Peer id=${e.id} addr=${e.addr}').join('\n'),
          child: SailText.secondary12(formatTimeDifference(widget.count, 'peer')),
        ),
      ),
    );
  }
}
