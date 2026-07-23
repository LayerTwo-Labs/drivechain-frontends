import "server-only";

import { createConnectTransport as createConnectServerTransport } from "@connectrpc/connect-node";

let logged = false;

export async function getServerTransport() {
  const apiBaseUrl = process.env.API_BASE_URL ?? "http://localhost:8082";
  if (!logged) {
    console.log("Server transport: using API base URL:", apiBaseUrl);
    logged = true;
  }

  return createConnectServerTransport({
    baseUrl: apiBaseUrl,
    httpVersion: "1.1",
  });
}
