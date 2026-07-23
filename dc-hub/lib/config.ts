import "server-only";

import type { DrivechainConfig, NetworkConfig } from "@/lib/network";

// The deployment catalog: which networks exist and which services run on
// each. Fetched fresh per request — it's a tiny static file behind a CDN,
// and the whole app renders dynamically anyway (layout.tsx force-dynamic).
// Next memoizes identical GET fetches within a render pass, so the layout,
// metadata and page share one request.
const CONFIG_URL = process.env.CONFIG_URL ?? "https://drivechain.dev/config";

function parseConfig(raw: unknown): DrivechainConfig {
  const config = raw as DrivechainConfig;
  if (!Array.isArray(config?.networks) || config.networks.length === 0) {
    throw new Error(`malformed config from ${CONFIG_URL}: missing networks`);
  }
  for (const net of config.networks) {
    if (typeof net.id !== "string" || typeof net.services !== "object") {
      throw new Error(`malformed config from ${CONFIG_URL}: bad network entry`);
    }
  }
  return config;
}

export async function getDrivechainConfig(): Promise<DrivechainConfig> {
  const res = await fetch(CONFIG_URL, { cache: "no-store" });
  if (!res.ok) {
    throw new Error(`GET ${CONFIG_URL}: ${res.status} ${res.statusText}`);
  }
  return parseConfig(await res.json());
}

/** Resolve this deployment's network entry from the NETWORK env var. */
export async function getNetworkConfig(): Promise<NetworkConfig> {
  const id = process.env.NETWORK ?? "signet";
  const config = await getDrivechainConfig();
  const network = config.networks.find((net) => net.id === id);
  if (!network) {
    const known = config.networks.map((net) => net.id).join(", ");
    throw new Error(`Network "${id}" not present in ${CONFIG_URL} — known networks: ${known}`);
  }
  return network;
}
