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

export function shortHex(hex: string, head = 6, tail = 4): string {
  if (hex.length <= head + tail + 2) return hex;
  return `${hex.slice(0, head)}…${hex.slice(-tail)}`;
}

export function topicLabel(topicHex: string, name?: string): string {
  if (name && name.length > 0) return name;
  // Topic IDs are 4-byte hex; render as ASCII when printable, else hex.
  try {
    const bytes = hexToBytes(topicHex);
    if (bytes.every((b) => b >= 0x20 && b < 0x7f)) {
      return new TextDecoder().decode(bytes);
    }
  } catch {
    // fall through
  }
  return topicHex;
}

function hexToBytes(hex: string): Uint8Array {
  const out = new Uint8Array(hex.length / 2);
  for (let i = 0; i < out.length; i++) {
    out[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  }
  return out;
}
