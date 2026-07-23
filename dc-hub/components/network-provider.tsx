"use client";

import { createContext, useContext } from "react";
import type { NetworkConfig } from "@/lib/network";

// Carries the deployment's network config (resolved server-side from the
// NETWORK env var + drivechain.dev/config in the root layout) into client
// components.
const NetworkContext = createContext<NetworkConfig | null>(null);

export function NetworkProvider({
  network,
  children,
}: {
  network: NetworkConfig;
  children: React.ReactNode;
}) {
  return <NetworkContext.Provider value={network}>{children}</NetworkContext.Provider>;
}

export function useNetwork(): NetworkConfig {
  const network = useContext(NetworkContext);
  if (network === null) {
    throw new Error("useNetwork must be used within a NetworkProvider");
  }
  return network;
}
