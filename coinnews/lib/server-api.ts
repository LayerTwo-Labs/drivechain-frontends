import "server-only";

import { createConnectTransport } from "@connectrpc/connect-node";
import { createClient } from "@connectrpc/connect";
import { CoinNewsService } from "@/gen/coinnews/v1/coinnews_pb";

let logged = false;

export function getServerTransport() {
  const apiBaseUrl = process.env.API_BASE_URL ?? "http://localhost:8080";
  if (!logged) {
    console.log("Server transport: using API base URL:", apiBaseUrl);
    logged = true;
  }

  return createConnectTransport({
    baseUrl: apiBaseUrl,
    httpVersion: "1.1",
  });
}

export function getServerClient() {
  return createClient(CoinNewsService, getServerTransport());
}
