// Network identity and per-network parameters.
//
// The network is a RUNTIME concern (`NETWORK` env var, e.g. `docker run -e
// NETWORK=drynet1`): one image serves every network. Server components read
// it via serverNetwork(); client components receive it through
// <NetworkProvider>/useNetwork(). Everything else in this file is a pure
// function of the network name.

// The complete set of networks. This is the single source of truth: adding a
// network here forces every `Record<Network, ...>` lookup below to gain an
// entry, or the build fails. That is what turns "unknown network" from a
// runtime crash into a compile error.
export const NETWORKS = ["signet", "forknet", "drynet1", "drynet2"] as const;
export type Network = (typeof NETWORKS)[number];

function isNetwork(value: string): value is Network {
  return (NETWORKS as readonly string[]).includes(value);
}

/** Server-side only: resolve the network from the environment per request.
 * (Falls back to the legacy build-time var, then signet.) This is the ONE
 * runtime boundary where an arbitrary string becomes a typed Network;
 * everything downstream is exhaustively checked at compile time. */
export function serverNetwork(): Network {
  const raw = process.env.NETWORK ?? process.env.NEXT_PUBLIC_NETWORK ?? "signet";
  if (!isNetwork(raw)) {
    throw new Error(`Unknown NETWORK "${raw}" — expected one of: ${NETWORKS.join(", ")}`);
  }
  return raw;
}

/** Dry-run forknets (drynet1, drynet2, ...) have no faucet: coins come from
 * mining. The explorer + connect info are the whole point of the site there. */
export function faucetEnabled(network: Network): boolean {
  return !network.startsWith("drynet");
}

/** Networks with an internal "Info" page (connection instructions) instead
 * of the external drivechain.info link. */
export function hasConnectInfoPage(network: Network): boolean {
  return network.startsWith("drynet");
}

const EXAMPLE_ADDRESS: Record<Network, string> = {
  signet: "tb1quez8thg0py02vl8gj98efa08tc0zfwuctc6d7j",
  forknet: "bc1q4akxjffcy6f4tyhj6d5xjfyqqzh7vnqag06v3x",
  drynet1: "bc1q4akxjffcy6f4tyhj6d5xjfyqqzh7vnqag06v3x",
  drynet2: "bc1q4akxjffcy6f4tyhj6d5xjfyqqzh7vnqag06v3x",
};

export function exampleAddressForNetwork(network: Network): string {
  return EXAMPLE_ADDRESS[network];
}

// Non-standard ports on the drynet hosts: they also serve mainnet, which
// already holds the standard explorer subdomains.
const BLOCK_EXPLORER_BASE: Record<Network, string> = {
  signet: "https://explorer.drivechain.info",
  forknet: "https://explorer.forknet.drivechain.info",
  drynet1: "https://explorer.drynet1.drivechain.dev",
  drynet2: "https://explorer.drynet2.drivechain.dev",
};

function blockExplorerBase(network: Network): string {
  return BLOCK_EXPLORER_BASE[network];
}

export function blockExplorerUrl(network: Network, txid: string): string {
  return `${blockExplorerBase(network)}/tx/${txid}`;
}

export function blockExplorerBlockUrl(network: Network, blockHash: string): string {
  return `${blockExplorerBase(network)}/block/${blockHash}`;
}
