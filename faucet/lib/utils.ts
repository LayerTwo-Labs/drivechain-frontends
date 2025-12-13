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

export function blockExplorerUrl(txid: string): string {
  switch (instanceNetwork()) {
    case "signet":
      return `https://explorer.drivechain.info/tx/${txid}`;
    case "forknet":
      return `https://explorer.forknet.drivechain.info/tx/${txid}`;
    default:
      throw new Error(`No block explorer URL for network: ${instanceNetwork()}`);
  }
}
