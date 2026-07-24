// Types and pure helpers for the deployment's network config.
//
// The source of truth is https://drivechain.dev/config: a catalog of every
// network we operate, with the services deployed on each. The NETWORK env
// var (e.g. `docker run -e NETWORK=drynet3`) selects which entry applies to
// this deployment — see lib/config.ts for the server-side fetch. Client
// components receive the resolved entry through <NetworkProvider>/useNetwork().
//
// Everything in this file is client-safe: plain types and pure functions of
// the config object.

export interface Currency {
  name: string;
  ticker: string;
}

export interface Backend {
  // "esplora" | "electrum" | future kinds — kept open so new backends in the
  // config don't break old deployments.
  kind: string;
  url: string;
  tls: boolean;
  label: string;
}

export interface FaucetService {
  // null when this network has no faucet deployed.
  url: string | null;
  // Maximum amount dispensed per request, in whole coins.
  amount: number | null;
  cooldown_seconds: number | null;
}

export interface UrlService {
  url: string | null;
}

export interface Services {
  faucet: FaucetService;
  coinnews: UrlService;
  blockbook: UrlService;
  fast_withdrawal: { url: string }[];
}

export interface P2p {
  // host:port of a public bitcoind peer, for -addnode. No URL scheme.
  address: string;
}

export interface AssumeUtxo {
  url: string;
  height: number;
  sha256: string;
  size_bytes: number;
}

export interface NetworkConfig {
  id: string;
  family: string;
  display_name: string;
  description: string;
  chain: string;
  currency: Currency;
  backends: Backend[];
  // null when the network runs no block-explorer tier.
  explorer_tx_template: string | null;
  explorer_address_template: string | null;
  explorer_block_template: string | null;
  services: Services;
  p2p: P2p | null;
  assumeutxo: AssumeUtxo | null;
}

export interface DrivechainConfig {
  schema_version: number;
  networks: NetworkConfig[];
}

/** Whether this deployment has a faucet. Networks without one (drynets:
 * coins come from mining) land on the sidechains overview instead. */
export function faucetEnabled(net: NetworkConfig): boolean {
  return net.services.faucet.url !== null;
}

export function blockExplorerUrl(net: NetworkConfig, txid: string): string | null {
  return net.explorer_tx_template?.replace("{txid}", txid) ?? null;
}

export function blockExplorerBlockUrl(net: NetworkConfig, blockHash: string): string | null {
  return net.explorer_block_template?.replace("{hash}", blockHash) ?? null;
}

/** The explorer's landing page, for links that don't target a specific tx. */
export function blockExplorerBase(net: NetworkConfig): string | null {
  return net.explorer_block_template ? new URL(net.explorer_block_template).origin : null;
}

export function findBackend(net: NetworkConfig, kind: string): Backend | undefined {
  return net.backends.find((b) => b.kind === kind);
}

export const RELEASES_BASE = "https://releases.drivechain.info";

const L1_BINARY_TARGETS = [
  { target: "aarch64-apple-darwin", label: "macOS (Apple Silicon)" },
  { target: "x86_64-apple-darwin", label: "macOS (Intel)" },
  { target: "x86_64-unknown-linux-gnu", label: "Linux (x86_64)" },
  { target: "x86_64-w64-msvc", label: "Windows (x86_64)" },
];

export interface BinaryLink {
  label: string;
  url: string;
}

/** Prebuilt L1 node binaries for this network on releases.drivechain.info,
 * named `L1-ecash-bitcoin-<network id>-<target>.zip` there. Only the ecash
 * family gets per-network builds (each fork is its own chain); other
 * families return null. */
export function l1Binaries(net: NetworkConfig): BinaryLink[] | null {
  if (net.family !== "ecash") return null;
  return L1_BINARY_TARGETS.map(({ target, label }) => ({
    label,
    url: `${RELEASES_BASE}/L1-ecash-bitcoin-${net.id}-${target}.zip`,
  }));
}

const EXAMPLE_ADDRESS_BY_CHAIN: Record<string, string> = {
  main: "bc1q4akxjffcy6f4tyhj6d5xjfyqqzh7vnqag06v3x",
  signet: "tb1quez8thg0py02vl8gj98efa08tc0zfwuctc6d7j",
};

export function exampleAddress(net: NetworkConfig): string {
  return EXAMPLE_ADDRESS_BY_CHAIN[net.chain] ?? EXAMPLE_ADDRESS_BY_CHAIN.main;
}
