import { Code, ConnectError } from "@connectrpc/connect";
import { instanceNetwork } from "@/lib/utils";

// Turns the backend's raw dispense errors into something a user can act on.
// The Bitcoin Core node stays the source of truth, this just makes its
// messages readable instead of dumping "[internal] dispense coins: -5: ...".
export function dispenseErrorMessage(err: unknown): string {
  const connectErr = ConnectError.from(err);
  const raw = connectErr.rawMessage.toLowerCase();

  if (raw.includes("address") || raw.includes("checksum")) {
    return `That doesn't look like a valid ${instanceNetwork()} address. Double-check it and try again.`;
  }
  if (raw.includes("amount")) {
    return "Amount must be greater than 0 and at most 5 BTC.";
  }
  if (connectErr.code === Code.ResourceExhausted || raw.includes("insufficient")) {
    return "The faucet is temporarily out of funds or rate-limited. Please try again later.";
  }
  return "Could not dispense coins. Please try again.";
}
