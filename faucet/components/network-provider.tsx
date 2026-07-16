"use client";

import { createContext, useContext } from "react";
import type { Network } from "@/lib/network";

// Carries the runtime network name (resolved server-side from the NETWORK
// env var in the root layout) into client components.
const NetworkContext = createContext<Network | null>(null);

export function NetworkProvider({
  network,
  children,
}: {
  network: Network;
  children: React.ReactNode;
}) {
  return <NetworkContext.Provider value={network}>{children}</NetworkContext.Provider>;
}

export function useNetwork(): Network {
  const network = useContext(NetworkContext);
  if (network === null) {
    throw new Error("useNetwork must be used within a NetworkProvider");
  }
  return network;
}
