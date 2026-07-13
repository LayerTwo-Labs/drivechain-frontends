"use client";

import { createContext, useContext } from "react";

// Carries the runtime network name (resolved server-side from the NETWORK
// env var in the root layout) into client components.
const NetworkContext = createContext<string | null>(null);

export function NetworkProvider({
  network,
  children,
}: {
  network: string;
  children: React.ReactNode;
}) {
  return <NetworkContext.Provider value={network}>{children}</NetworkContext.Provider>;
}

export function useNetwork(): string {
  const network = useContext(NetworkContext);
  if (network === null) {
    throw new Error("useNetwork must be used within a NetworkProvider");
  }
  return network;
}
