import 'package:bitwindow/providers/mining_pools_provider.dart';
import 'package:sail_ui/sail_ui.dart';

/// A pools provider that holds [pools] and never calls bitwindowd.
class FakeMiningPools extends MiningPoolsProvider {
  FakeMiningPools(List<MiningPoolShare> shares) {
    pools = shares;
    blockCount = shares.fold(0, (sum, share) => sum + share.blockCount);
    fromHeight = 23410;
    toHeight = 23410 + blockCount - 1;
    networkHashrate = 2.4e18;
    registryAvailable = true;
    registrySource = 'pool.drivechain.info';
  }

  @override
  Future<void> fetch() async {}
}

/// One pool's share of a 144-block window.
MiningPoolShare poolShare(String name, String stratumUrl, int blocks, {int feeBps = 100, String mode = 'pplns'}) {
  return MiningPoolShare(
    pool: MiningPool(
      name: name,
      slug: name.toLowerCase(),
      stratumUrl: stratumUrl,
      feeBps: feeBps,
      mode: stratumUrl.isEmpty ? '' : mode,
    ),
    blockCount: blocks,
    share: blocks / 144,
    estimatedHashrate: 2.4e18 * blocks / 144,
  );
}
