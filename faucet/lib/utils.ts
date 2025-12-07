import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// TODO: add support for forknet through build time environment variable
export function instanceNetwork(): string {
  return "signet";
}

export function exampleAddressForNetwork(): string {
  switch (instanceNetwork()) {
    case "signet":
      return "tb1quez8thg0py02vl8gj98efa08tc0zfwuctc6d7j";
    default:
      throw new Error(`No example address for network: ${instanceNetwork()}`);
  }
}

export function blockExplorerUrl(txid: string): string {
  switch (instanceNetwork()) {
    case "signet":
      return `https://explorer.drivechain.info/tx/${txid}`;
    default:
      throw new Error(`No block explorer URL for network: ${instanceNetwork()}`);
  }
}
