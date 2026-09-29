/// The URL scheme the app answers to.
const String truthcoinScheme = 'truthcoin';

/// A link another program hands to the app.
sealed class TruthcoinLink {
  const TruthcoinLink();
}

/// `truthcoin://market/<marketId>`
class MarketLink extends TruthcoinLink {
  final String marketId;

  const MarketLink(this.marketId);

  @override
  bool operator ==(Object other) => other is MarketLink && other.marketId == marketId;

  @override
  int get hashCode => marketId.hashCode;
}

/// `truthcoin://markets`
class MarketListLink extends TruthcoinLink {
  const MarketListLink();

  @override
  bool operator ==(Object other) => other is MarketListLink;

  @override
  int get hashCode => 0;
}

/// A market id holds hex from the node, so anything else is a bad link.
/// The openapi schema writes the id with a 0x prefix, so a link may carry it.
final RegExp _marketId = RegExp(r'^(?:0[xX])?[0-9a-fA-F]{4,64}$');

String _stripHexPrefix(String id) =>
    id.length > 2 && (id.startsWith('0x') || id.startsWith('0X')) ? id.substring(2) : id;

/// Reads a link the operating system hands over. Answers null for every link
/// the app does not own, and for a market id the node cannot hold.
TruthcoinLink? parseTruthcoinLink(Uri uri) {
  if (uri.scheme.toLowerCase() != truthcoinScheme) return null;

  final segments = [
    if (uri.host.isNotEmpty) uri.host,
    ...uri.pathSegments.where((s) => s.isNotEmpty),
  ];
  if (segments.isEmpty) return null;

  switch (segments.first.toLowerCase()) {
    case 'markets':
      return segments.length == 1 ? const MarketListLink() : null;
    case 'market':
      if (segments.length != 2) return null;
      final id = segments[1];
      return _marketId.hasMatch(id) ? MarketLink(_stripHexPrefix(id)) : null;
    default:
      return null;
  }
}
