import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const network = process.env.NEXT_PUBLIC_NETWORK ?? "signet";
if (!network) {
  throw new Error("ended up with empty bitcoin network");
}

export function instanceNetwork(): string {
  return network;
}

// Loose sanity check to catch empty or obviously typo'd input before we hit
// the node. Intentionally does not verify the checksum or network, the faucet's
// Bitcoin Core node is the source of truth, so this stays permissive to avoid
// rejecting a valid address.
export function isPlausibleAddress(address: string): boolean {
  const addr = address.trim();
  const bech32 = /^(bc|tb|bcrt)1[a-z0-9]{6,87}$/i;
  const base58 = /^[123mn][1-9A-HJ-NP-Za-km-z]{24,38}$/;
  return bech32.test(addr) || base58.test(addr);
}

export function exampleAddressForNetwork(): string {
  switch (instanceNetwork()) {
    case "signet":
      return "tb1quez8thg0py02vl8gj98efa08tc0zfwuctc6d7j";
    case "forknet":
      return "bc1q4akxjffcy6f4tyhj6d5xjfyqqzh7vnqag06v3x";
    default:
      throw new Error(`No example address for network: ${instanceNetwork()}`);
  }
}

function blockExplorerBase(): string {
  switch (instanceNetwork()) {
    case "signet":
      return "https://explorer.drivechain.info";
    case "forknet":
      return "https://explorer.forknet.drivechain.info";
    default:
      throw new Error(`No block explorer URL for network: ${instanceNetwork()}`);
  }
}

export function blockExplorerUrl(txid: string): string {
  return `${blockExplorerBase()}/tx/${txid}`;
}

export function blockExplorerBlockUrl(blockHash: string): string {
  return `${blockExplorerBase()}/block/${blockHash}`;
}
