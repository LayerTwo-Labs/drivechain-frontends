// Network identity and per-network parameters.
//
// The network is a RUNTIME concern (`NETWORK` env var, e.g. `docker run -e
// NETWORK=drynet1`): one image serves every network. Server components read
// it via serverNetwork(); client components receive it through
// <NetworkProvider>/useNetwork(). Everything else in this file is a pure
// function of the network name.

/** Server-side only: resolve the network from the environment per request.
 * (Falls back to the legacy build-time var, then signet.) */
export function serverNetwork(): string {
  return process.env.NETWORK ?? process.env.NEXT_PUBLIC_NETWORK ?? "signet";
}

/** Dry-run forknets (drynet1, drynet2, ...) have no faucet: coins come from
 * mining. The explorer + connect info are the whole point of the site there. */
export function faucetEnabled(network: string): boolean {
  return !network.startsWith("drynet");
}

/** Networks with an internal "Info" page (connection instructions) instead
 * of the external drivechain.info link. */
export function hasConnectInfoPage(network: string): boolean {
  return network.startsWith("drynet");
}

export function exampleAddressForNetwork(network: string): string {
  switch (network) {
    case "signet":
      return "tb1quez8thg0py02vl8gj98efa08tc0zfwuctc6d7j";
    case "forknet":
    case "drynet1":
    case "drynet2":
      return "bc1q4akxjffcy6f4tyhj6d5xjfyqqzh7vnqag06v3x";
    default:
      throw new Error(`No example address for network: ${network}`);
  }
}

function blockExplorerBase(network: string): string {
  switch (network) {
    case "signet":
      return "https://explorer.drivechain.info";
    case "forknet":
      return "https://explorer.forknet.drivechain.info";
    case "drynet1":
      return "https://explorer.drynet1.drivechain.dev";
    case "drynet2":
      return "https://explorer.drynet2.drivechain.dev";
    default:
      throw new Error(`No block explorer URL for network: ${network}`);
  }
}

export function blockExplorerUrl(network: string, txid: string): string {
  return `${blockExplorerBase(network)}/tx/${txid}`;
}

export function blockExplorerBlockUrl(network: string, blockHash: string): string {
  return `${blockExplorerBase(network)}/block/${blockHash}`;
}
